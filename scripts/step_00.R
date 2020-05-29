# A script that verifies that all required libraries are installed. If not, it will install them.

print("*** Checking that all required libraries are installed ***")

# Check if BiocManager is installed. If not, install it
if (!requireNamespace("BiocManager", quietly = TRUE)){
  install.packages("BiocManager")}

# Install Bioconductor packages that are not installed yet
print("*** Checking that required Bioconductor packages are installed ***")
bioc_packages <- c("DESeq2", "genefilter")
for (i in 1:length(bioc_packages)){
  if (!requireNamespace(bioc_packages[i], quietly = TRUE)){
    print(paste("Installing the following package with BiocManager:", bioc_packages[i]))
    BiocManager::install(bioc_packages[i])
  } else {print(paste(bioc_packages[i], "is installed"))}
}


packages <- c("dplyr", "factoextra", "forestmangr", "ggplot2",
              "jsonlite", "knitr", "readr", "rmarkdown", "stringr",
              "grid", "gridExtra")
print("*** Checking that required CRAN packages are installed ***")
for (j in 1:length(packages)){
  if (length(setdiff(packages[j], rownames(installed.packages()))) > 0) {
    print(paste("Installing the following package:", packages[j]))
    install.packages(packages[j])
  } else {print(paste(packages[j], "is installed"))}
}

