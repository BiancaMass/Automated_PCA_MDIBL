# A script that checks for consistency between the matrix
# and the design file. It prints out and saves a summary of each.

# **********************************************************************
args = commandArgs(trailingOnly = T)
print(args)
path2_json_file = args[1]
# **********************************************************************

# Load the necessary libraries
print("*** Loading libraries ***")
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

print("*** Checking that matrix and design file exist and are not empty ***")

# Check that the matrix and design files exist:
inputs = c(path2_counts, path2_design)
for (i in 1:length(inputs)){
  exis = file.exists(inputs[i])
  if (exis == FALSE){
    print(c("--- Error: the input file does not exist. Path to input:",inputs[i]), quote = FALSE)
    stop()
  }
}
# Checking tha the matrix and design files are not empty:
for (i in 1:length(inputs)){
  info = file.info(inputs[i])
  if (info$size <= 0){
    print(c("--- Error: the input file is empty. Path to input:",inputs[i]), quote = FALSE)
    stop()
  }
}

print("*** Reading the design and estimated counts files ***")
design = read.table(path2_design, header = TRUE, sep = "\t", row.names = 1)
counts = read.table(path2_counts, header = TRUE, sep = "\t", row.names = 1)

print("Checking that the est. counts matrix has no NAs")
##Check that the matrix has no NAs. If there are, print a warning message:
if(sum(is.na(counts)) > 0){
  print('--- Error: there are NAs in the count matrix')
}

print("*** Checking for a 1-1 correspondence between sample names in the two files ***")
# Checking for a 1-1 correspondence between the rownames of the design file and the column names
# of the estimated counts file.
# If there is no correspondence, it prints the names that do not match, and stops the program

for (i in 1:length(rownames(design)==colnames(counts))){
  if ((rownames(design)==colnames(counts))[i] ==  FALSE){
    print("--- Error: There is not a 1-1 correspondence between samples in the design and count files", quote = FALSE)
    print("samples not matching:", quote = FALSE)
    print(rownames(design)[i])
    print(colnames(counts)[i])
    stop()
  }
}

print("*** Head of the estimated counts ***", quote = FALSE)
print(head(counts))

print("*** Summary of the estimated counts file ***", quote = FALSE)
print(summary(counts))

# Print the head of counts matrix and design files to the terminal
print("*** Head of the design file ***", quote = FALSE)
print(head(design))


# Save a copy of the design file in the results folder
print("*** Creating a copy of the design file ***")
file2_design_copy = file.path(parent_folder, "results", paste0(experiment, "_design.txt"))
write.table(design,
            file = file2_design_copy,
            sep = "\t")

# Save the path to the design file into a new copy of the JSON file (this will be used in the report generation)
print("*** Creating a copy of the JSON file ***")
json_copy = json
path_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy$path_2_results$design_file = file2_design_copy
write_json(json_copy, path_json_copy, auto_unbox = TRUE)

