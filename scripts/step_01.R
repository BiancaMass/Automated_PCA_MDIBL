# A script that checks for consistency between the matrix
# and the design file. It prints out and saves a summary of each.

# **********************************************************************
args = commandArgs(trailingOnly = T)
print(args)
path2_json_file = args[1]
# **********************************************************************

# Hard coded to test
#path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

# Load the necessary libraries
print("Loading libraries: jsonlite")
options(stringsAsFactors = FALSE)
library(jsonlite)

# **********************************************************************

print("*** Reading the JSON file that contains paths to all input files ***")
json = read_json(path2_json_file)

# Extract the input file paths from json
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = json$"input_files"$"infile1"
path2_counts = json$"input_files"$"infile2"

print("Path to design and est.counts:")
print(path2_design)
print(path2_counts)

# Check that the matrix and design files exist:
inputs = c(path2_counts, path2_design)
for (i in 1:length(inputs)){
  exis = file.exists(inputs[i])
  if (exis == FALSE){
    print(c("Error: the input file does not exist. Path to input:",inputs[i]), quote = FALSE)
    stop()
  }
}

# Checking tha the matrix and design files are not empty:
for (i in 1:length(inputs)){
  info = file.info(inputs[i])
  if (info$size <= 0){
    print(c("Error: the input file is empty. Path to input:",inputs[i]), quote = FALSE)
    stop()
  }
}

print("*** Reading the design and estimated counts files ***")
design = read.table(path2_design, header = TRUE, sep = "\t", row.names = 1)
counts = read.table(path2_counts, header = TRUE, sep = "\t", row.names = 1)

##Check that the matrix has no NAs. If there are, print a warning message:
if(sum(is.na(counts)) > 0){
  print('--- Warning: there are NAs in the count matrix')
}

# Print the head of counts matrix and design files to the terminal
print("*** Design file ***", quote = FALSE)
print(head(design))

print("*** Estimated counts ***", quote = FALSE)
print(head(counts))

# Checking for a 1-1 correspondence between the rownames of the design file and the column names
# of the estimated counts file.
# If there is no correspondence, it prints the names that do not match, and stops the program

for (i in 1:length(rownames(design)==colnames(counts))){
  if ((rownames(design)==colnames(counts))[i] ==  FALSE){
    print("Error: There is not a 1-1 correspondence between samples in the design and count files", quote = FALSE)
    print("samples not matching:", quote = FALSE)
    print(rownames(design)[i])
    print(colnames(counts)[i])
    stop()
  }
}

print("*** Summary of the estimated counts file ***", quote = FALSE)
print(summary(counts))

# Save a copy of the design file in the results folder

write.table(design,
            file = file.path(parent_folder, "results", paste0(experiment, "_design.txt")),
            sep = "\t")

# 
# This creates a latex document that is convertible into a pdf by writing in the command line the following:
# pdflatex myfile.tex
# and it will create a myfile.pdf
# library('rmarkdown')
# rmarkdown::render(input = "~/Documents/senior_project/automated_pca/scripts/step_01.R",
#                   output_format = "pdf_document",
#                   output_file = "~/Documents/senior_project/automated_pca/report/deleteme.pdf",
                  # output_dir = NULL,
                  # output_options = NULL,
                  # output_yaml = NULL,
                  # intermediates_dir = NULL,
                  # knit_root_dir = NULL,
                  # runtime = c("auto", "static", "shiny", "shiny_prerendered"),
                  # clean = TRUE,
                  # params = NULL,
                  # knit_meta = NULL,
                  # envir = parent.frame(),
                  # run_pandoc = TRUE,
                  # quiet = FALSE,
                  # encoding = "UTF-8"
#                   )




