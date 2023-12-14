library(shiny)
library(shinythemes)
library(bslib)
library(dplyr)
library(ggplot2)
library(ggExtra)
library(Amelia)
library(caTools)
library(data.table)
library(RCurl)
library(caret)
library(pROC)

# variable	class	description
# https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-08-15/readme.md
################################################################
# variable	(class)	description
# crl.tot	(double)	Total length of uninterrupted sequences of capitals
# dollar	(double)	Occurrences of the dollar sign, as percent of total number of characters
# bang	(double)	Occurrences of ‘!’, as percent of total number of characters
# money	(double)	Occurrences of ‘money’, as percent of total number of characters
# n000	(double)	Occurrences of the string ‘000’, as percent of total number of words
# make	(double)	Occurrences of ‘make’, as a percent of total number of words
# yesno	(character)	Outcome variable, a factor with levels 'n' not spam, 'y' spam
################################################################

spam <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-08-15/spam.csv')
spam <- spam %>% mutate(isspam = if_else(.$yesno == "y", 1, 0))

missmap(spam, main = "Missing values vs observed")

# Use 80% of dataset as training set and 20% as test set
set.seed(123)
training.samples <- spam$isspam %>% createDataPartition(p = 0.8, list = FALSE)
train.data  <- spam[training.samples, ]
test.data <- spam[-training.samples, ]

# Fit the model
model <- glm(isspam ~ crl.tot + dollar + bang + money + n000 + make, data = train.data, family = binomial)
summary(model)
# Make predictions
probabilities <- model %>% predict(test.data, type = "response")
predicted.classes <- ifelse(probabilities > 0.5, 1, 0)
# Model accuracy
mean(predicted.classes == test.data$isspam)

test_prob = predict(model, newdata = test.data, type = "response")
test_roc = roc(test.data$isspam ~ test_prob, plot = TRUE, print.auc = TRUE)

####################################
####################################
# Save model to RDS file
saveRDS(model, "model.rds")
# Read in the RF model
model <- readRDS("model.rds")

####################################
# User interface                   #
####################################

ui <- fluidPage(theme = shinytheme("cerulean"),
                
                # Page header
                headerPanel('Is Spam?'),
                
                # Input values
                sidebarPanel(
                  HTML("<h3>Input parameters</h3>"),
                  
                  numericInput("crl.tot", label = "Total length of uninterrupted sequences of capitals:", 
                              min = 0, max = 500,
                              value = 10),
                  sliderInput("dollar", "Occurrences of the $ sign (% of total characters):",
                              min = 0.0, max = 1.0,
                              value = 0.0),
                  sliderInput("bang", "Occurrences of ‘!’ (% of total characters):",
                              min = 0.0, max = 1.0,
                              value = 0.0),
                  sliderInput("money", "Occurrences of ‘money’ (% of total characters):",
                              min = 0.0, max = 1.0,
                              value = 0.0),
                  sliderInput("n000", "Occurrences of the string ‘000’ (% of total characters):",
                              min = 0.0, max = 1.0,
                              value = 0.0),
                  sliderInput("make", "Occurrences of ‘make’ (% of total characters):",
                              min = .00, max = 1.0,
                              value = 0.0),
                  
                  actionButton("submitbutton", "Submit", class = "btn btn-primary")
                ),
                
                mainPanel(
                  tags$label(h3('Status/Output')), # Status/Output Text Box
                  verbatimTextOutput('contents'),
                  tableOutput('tabledata'), # Prediction results table
                  
                  # Output: Histogram ----
                  plotOutput(outputId = "distPlot")
                )
)

####################################
# Server                           #
####################################

server <- function(input, output, session) {
  
  # Input Data
  datasetInput <- reactive({  
    
    #"crl.tot", "dollar", "bang", "money", "n000","make"
    df <- data.frame(
      Name = c("crl.tot",
               "dollar",
               "bang",
               "money",
               "n000",
               "make"),
      Value = as.character(c(input$crl.tot,
                             input$dollar,
                             input$bang,
                             input$money,
                             input$n000,
                             input$make)),
      stringsAsFactors = FALSE)
    
    isspam <- "isspam"
    df <- rbind(df, isspam)
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test <- read.csv(paste("input", ".csv", sep=""), header = TRUE)
    
    probabilidades <- predict(model, newdata = test, type = "response")
    
    Output <- data.frame(probabilidad = probabilidades, decision = ifelse(probabilidades > 0.5, "si", "no"))
    print(Output)
    
  })
  
  # Status/Output Text Box
  output$contents <- renderPrint({
    if (input$submitbutton>0) { 
      isolate("Calculation complete.") 
    } else {
      return("Server is ready for calculation.")
    }
  })
  
  # Prediction results table
  output$tabledata <- renderTable({
    if (input$submitbutton>0) { 
      isolate(datasetInput()) 
    } 
  })
  
  output$distPlot <- renderPlot({
    test_roc = roc(test.data$isspam ~ test_prob, plot = TRUE, print.auc = TRUE)
  })
  
}

####################################
# Create the shiny app             #
####################################

shinyApp(ui = ui, server = server)


