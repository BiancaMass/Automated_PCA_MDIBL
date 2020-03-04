# A script that normalizes the expression matrix using rlog()

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# **********************************************************************

# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

# Load the necessary libraries
options(stringsAsFactors = FALSE)
library(jsonlite)
library(forestmangr)
library(DESeq2)
library(genefilter)
library(stringr)

# **********************************************************************

# Reading the json file with the file paths
json = read_json(path2_json_file)

# Extract the input file paths and variables from json
parent_folder = json[[1]]$"folders"$"parent_folder"
experiment = json[[1]]$"input_files"$"experiment_name"
path2_design = json[[1]]$"input_files"$"infile1"
path2_counts = json[[1]]$"input_files"$"infile2"
min_mean = json[[1]]$"input_varibles"$"min_count_mean"

# Read in the design and estimated counts files
design = read.table(path2_design, header = TRUE, sep = "\t", row.names = 1)
counts = read.table(path2_counts, header = TRUE, sep = "\t", row.names = 1)

# Round the count matrix, remove rows of <= 1 counts, and filter for row with a mean above the
# mean threshold set in the JSON file
counts <- round_df(counts, digits = 0, rf = "round")
counts = subset(counts, rowSums(counts)>1)
counts = subset(counts, apply(counts, 1, mean) > min_mean)

## Check that the numbers in the count matrix are positive and integers.
## If not, throw and error message and stop the program.
if (any(counts < 0 )) { print("Error: not all numbers in the count matrix are positive.");
  stop()
}

if (sum(counts != apply(counts, 2, as.integer)) > 0) { print("Error: not all numbers in the rounded count matrix are integers");
  stop()
}

# Calculating mean and sd for each gene across all samples:

counts_mean = apply(counts, 1, mean, na.rm = TRUE)
counts_stdev = apply(counts, 1, sd, na.rm = TRUE)

# plot(counts_mean, counts_stdev)

# Save the matrix of gene means
output_mean = file.path(parent_folder, "results", paste0(experiment, "_genecounts_means.txt"))
write.table(counts_mean, file = output_mean, sep = '\t')
# Save the matrix of gene standard deviations
output_sd = file.path(parent_folder, "results", paste0(experiment, "_genecounts_sd.txt"))
write.table(counts_stdev, file = output_sd, sep = '\t')

# Construct the DeSeq data set to apply rlog()
print("*** Constructing the DESeq Data set ***")

# Extract the additive covariates from the design file:
for (i in 1:(length(json[[1]]$additive_covar))){
  if (str_length(json[[1]]$additive_covar[[i]]) > 0){
    nam <- paste0("additive", i)
    print(nam)
    assign(nam, json[[1]]$additive_covar[[i]])
  }
}

# Extract the interactive covariates from the design file:
for (i in 1:(length(json[[1]]$interactive_covar))){
  if (str_length(json[[1]]$additive_covar[[i]]) > 0){
    nam <- paste0("additive", i)
    print(nam)
    assign(nam, json[[1]]$additive_covar[[i]])
  }
}

## Construct the DeSeq data set using the countdata (countmatrix) and coldata (sample information)
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = design,
                              design = ~ treatment
)

print("*** Normalizing the expression matrix using rlog or vst***")
print("*** This will take a few moments ***")

# Normalize the expression matrix using rlog (dataset with less than 30 samples)
# or vst (dataset with more than 30 samples)
# Write the normalized file to the results folder
if (ncol(assay(dds)) <=30) {
  rld <- rlog(dds, blind = FALSE)
  rld_assay <- assay(rld)
  output_matrix = file.path(parent_folder, "results", paste0(experiment,"_rld_normalized.txt"))
  write.table(rld_assay, file = output_matrix, sep = '\t')
} else {
   vsd <- vst(dds, blind = FALSE)
   vsd_assay <- assay(vsd)
   output_matrix = file.path(parent_folder, "results", paste0(experiment,"_vst_normalized.txt"))
   write.table(vsd_assay, file = output_matrix, sep = '\t')
}

