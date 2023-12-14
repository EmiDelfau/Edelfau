

La mejor forma que tengo de obtener un baseline sobre las capacidades técnicas con R/Shiny es dejar una temática abierta para que te explayes.


1) Se trabaja con información provista por Tidy Tuesday (https://github.com/rfordatascience/tidytuesday/tree/master). Particularmente con información de "Spam E-mail"* (https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-08-15/spam.csv).

* NOTE: This is a dataset collected at Hewlett-Packard Labs by Mark Hopkins, Erik Reeber, George Forman, and Jaap Suermondt and shared with the UCI Machine Learning Repository. The dataset classifies 4601 e-mails as spam or non-spam, with additional variables indicating the frequency of certain words and characters in the e-mail.

2) Se desarrolla una aplicación Shiny que trata de responder dos preguntas:
 I) El dataset sirve para predecir mediante un modelo de ML si las características de un email es spam? Para esto estimamos la bondad de ajuste del modelo mediante la métrica ROC.
 II) Dado el ROC (bondad de ajuste del modelo) utilizamos inputs para determinar qué variables son claves al momento de determinar si la probabilidad de que un email sea spam es mayor al 50%.
