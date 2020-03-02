# A script that normalizes the expression matrix using rlog()

args = base::commandArgs(trailingOnly = TRUE)
print(args)

path2_json_file = args[1]

# **********************************************************************

# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

# Load the necessary libraries
print("Loading libraries: jsonlite, forestmangr, DESeq2, genefilter")
options(stringsAsFactors = FALSE)
library(jsonlite)
library(forestmangr)
library(DESeq2)
library(genefilter)

# **********************************************************************

# Reading the json file with the file paths
json = read_json(path2_json_file)

# Extract the input file paths from json
parent_folder = json[[1]][["folders"]][["parent_folder"]]
experiment = json[[1]][["input_files"]][["experiment_name"]]
path2_design = json[[1]][["input_files"]][["infile1"]]
path2_counts = json[[1]][["input_files"]][["infile2"]]

design = read.table(path2_design, header = TRUE, sep = "\t", row.names = 1)
counts = read.table(path2_counts, header = TRUE, sep = "\t", row.names = 1)


## Round the count matrix:
counts <- round_df(counts, digits = 0, rf = "round")
# Remove the rows of all 0s from the count matrix
counts = subset(counts, rowSums(counts)>0)
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
## Construct the DeSeq data set using the countdata (count cdesmatrix) and coldata (sample information)
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = design,
                              design = ~ treatment
)

print("*** Normalizing the expression matrix using rlog()***")
print("*** This will take a few moments ***")
## Normalize the expression matrix using rlog().
rld <- rlog(dds, blind = FALSE)
## The assay function is used to extract the transformed values
rld_assay <- assay(rld)
# Write the matrix to a file in the output folder
print("*** Saving the normalized count matrix ***")
# Create an output path:
output_matrix = file.path(parent_folder, "results", paste0(experiment,"_rld_normalized.txt"))
print(paste(" Path to normalized matrix:", output_matrix ))

write.table(rld_assay, file = output_matrix, sep = '\t')

