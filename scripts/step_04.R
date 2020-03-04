# A script that reduces to genes with either sufficient variation or average
# expression level. Uses a threshold on A and/or SD.
# Thresholds comes in as a variables from the JSON input file.

args = base::commandArgs(trailingOnly = TRUE)
print(args)

path2_json_file = args[1]

# **********************************************************************
# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

# Load the necessary libraries
print("Loading libraries: jsonlite")
options(stringsAsFactors = FALSE)
library(jsonlite)

# Read in input files:

# JSON input file with SD and AVG thresholds
print("*** Reading the input files ***")
json = read_json(path2_json_file)

# Extracting the file paths from the JSON file
parent_folder = json[[1]][["folders"]][["parent_folder"]]
experiment = json[[1]][["input_files"]][["experiment_name"]]
input_Z = file.path(parent_folder, "results", paste0(experiment, "_Z_normalized.txt"))
path2_count_means = file.path(parent_folder, "results", paste0(experiment, "_genecounts_means.txt"))
path2_count_sd = file.path(parent_folder, "results", paste0(experiment, "_genecounts_sd.txt"))

# Extracting the mean and sd thresholds
# If they do not exist in the json, set them at 0.75%

if (is.na(json[[1]]$"input_varibles"$"mean_precentage_threshold")){
  mean_thr = 0.25
}

if (is.na(json[[1]]$"input_varibles"$"sd_precentage_threshold")){
  sd_thr = 0.25
}


mean_thr = json[[1]][["input_varibles"]][["mean_precentage_threshold"]]
sd_thr = json[[1]][["input_varibles"]][["sd_precentage_threshold"]]


# Read in the Z table, avg, and sd tables
print("*** Loading the normalized matrix, sd, and mean matrix from previous step ***")

Z = as.matrix(read.table(input_Z, sep = '\t', header = TRUE,  row.names = 1))
raw_means = as.matrix(read.table(path2_count_means, sep = '\t', row.names = 1))
raw_sd = as.matrix(read.table(path2_count_sd, sep = '\t', row.names = 1))

# plot(raw_means, raw_sd)

mean_quantile <- quantile(raw_means[,1] ,   probs = mean_thr)
sd_quantile <-   quantile(raw_sd[,1], probs = sd_thr)
mean_subset <- subset(raw_means, raw_means[,1]>mean_quantile)
sd_subset <- subset(raw_sd, raw_sd[,1] > sd_quantile)

nrow(raw_means) - nrow(mean_subset)
nrow(raw_sd) - nrow(sd_subset)

hist(log(raw_means), xlim = c(-1, 20), breaks = 100)
abline(v=log(mean_quantile), col = 'red')
# 
hist(log(raw_sd), xlim = c(-1, 20), breaks = 100)
abline(v=log(sd_quantile), col = 'red')


# Subsetting the data set for a min average and variance in expression levels
# The mean is the average gene expression
# low mean means the gene is not highly expressed across samples
# The sd relates to variation across samples

gene_id_mn = intersect(rownames(Z), rownames(mean_subset))
Z = Z[gene_id_mn,]
stopifnot(rownames(Z) == rownames(mean_subset))
gene_id_sd = intersect(rownames(Z), rownames(sd_subset))
Z = Z[gene_id_sd,]
#stopifnot(rownames(Z) == rownames(sd_subset))

outputfile_path = file.path(parent_folder, "results", paste0(experiment , "_Z_threshold.txt"))
write.table(Z, file = outputfile_path, sep = '\t')





