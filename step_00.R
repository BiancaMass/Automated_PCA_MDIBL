# A script that verifies that all required libraries are installed. If not, it stop() and gives an error message.

print("*** Checking that all required libraries are installed ***")

packages <- c("DESeq2", "dplyr", "factoextra", "forestmangr", "genefilter", "ggplot2",
              "jsonlite", "knitr", "readr", "rmarkdown", "stringr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  print("Please install the following packages:")
  print(setdiff(packages, rownames(installed.packages())))
  print("*** The pipeline will not run until all required packages are installed ***")
  stop()
} else {print("*** All required libraries are installed ***")}
