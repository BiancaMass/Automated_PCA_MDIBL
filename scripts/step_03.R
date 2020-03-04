# A script that performs Z-transformation on the count matrix
# Z = (x-mean) / sd
# where A and SD are the average and standard deviations 
# of expression for that gene across all samples.

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# **********************************************************************
# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

print("Loading libraries: genefilter, jsonlite")
options(stringsAsFactors = FALSE)
library(genefilter)
library(jsonlite)

# Load the necessary libraries
print("*** Reading the input files ***")
# Reading the json file with the file paths
json = read_json(path2_json_file)

# File paths to parent folder, and input file (normalized matrix from step_02.R i.e. rld or vsd matrix)
parent_folder = json[[1]]$"folders"$"parent_folder"
experiment = json[[1]]$"input_files"$"experiment_name"

if (file.exists(file.path(parent_folder, "results", paste0(experiment,"_rld_normalized.txt")))){
  input_matrix = file.path(parent_folder, "results", paste0(experiment,"_rld_normalized.txt"))
}

if (file.exists(file.path(parent_folder, "results", paste0(experiment,"_vst_normalized.txt")))){
  input_matrix = file.path(parent_folder, "results", paste0(experiment,"_vst_normalized.txt"))
}

# Read the input matrix
matrix_norm = read.table(input_matrix, sep = '\t', header = TRUE,  row.names = 1)

# Calculate the mean and standard deviation for the rlog normalized matrix, by row
# (i.e. for a gene across all samples)
mn = apply(matrix_norm, 1, mean, na.rm = TRUE)
stdev = apply(matrix_norm, 1, sd, na.rm = TRUE)

# Apply a Z-trasnformation, so that gene means = 0, gene sd = 1
Z = (matrix_norm - mn) / stdev

par(mfrow = c(1, 2))

## Generate plots
# plot(mn, stdev)
# plot(rowMeans(Z), genefilter::rowSds(Z))

print("*** Saving the output files to the results folder ***")
# Save the normalized matrix
output_Z = file.path(parent_folder, "results", paste0(experiment, "_Z_normalized.txt"))
write.table(Z, file = output_Z, sep = '\t')

