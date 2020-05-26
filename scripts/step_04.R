# A script that reduces to genes with either sufficient variation or average
# expression level. Uses a threshold on A and/or SD.
# Thresholds comes in as a variables from the JSON input file.

args = base::commandArgs(trailingOnly = TRUE)
print(args)

path2_json_file = args[1]

# **********************************************************************
# Load the necessary libraries
print("Loading libraries")
options(stringsAsFactors = FALSE)
options(bitmapType='cairo')
library(jsonlite)
library(ggplot2)

# Read in input files:

# JSON input file with SD and AVG thresholds
print("*** Reading the input files ***")
json = read_json(path2_json_file)

# Extracting the file paths from the JSON file
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
input_Z = file.path(parent_folder, "results", paste0(experiment, "_Z_normalized.txt"))
path2_count_means = file.path(parent_folder, "results", paste0(experiment, "_genecounts_means.txt"))
path2_count_sd = file.path(parent_folder, "results", paste0(experiment, "_genecounts_sd.txt"))

# Extracting the mean and sd thresholds
# If they do not exist in the json, set them at 0.25%

if (is.na(json$"input_variables"$"mean_precentage_threshold")){
  mean_thr = 0.25
} else{mean_thr = json$"input_variables"$"mean_precentage_threshold"}


if (is.na(json$"input_variables"$"sd_precentage_threshold")){
  sd_thr = 0.25
} else {sd_thr = json$"input_variables"$"sd_precentage_threshold"}


# Read in the Z table, avg, and sd tables
print("*** Loading the normalized matrix, sd, and mean matrix from previous step ***")
Z = as.matrix(read.table(input_Z, sep = '\t', header = TRUE,  row.names = 1))
raw_means = as.matrix(read.table(path2_count_means, sep = '\t', row.names = 1))
raw_sd = as.matrix(read.table(path2_count_sd, sep = '\t', row.names = 1))

mean_quantile <- quantile(raw_means[,1] ,   probs = mean_thr)
sd_quantile <-   quantile(raw_sd[,1], probs = sd_thr)
mean_subset <- subset(raw_means, raw_means[,1]>mean_quantile)
sd_subset <- subset(raw_sd, raw_sd[,1] > sd_quantile)

# Subsetting the data set for a min average and variance in expression levels
# The mean is the average gene expression
# low mean means the gene is not highly expressed across samples
# The sd relates to variation across samples
# Low sd means that the gene is expressed similarly across samples (treatment vs control)

gene_id_mn = intersect(rownames(Z), rownames(mean_subset))
Z = Z[gene_id_mn,]
stopifnot(rownames(Z) == rownames(mean_subset))
gene_id_sd = intersect(rownames(Z), rownames(sd_subset))
Z = Z[gene_id_sd,]
gene_ids = c(gene_id_mn, gene_id_sd)
gene_ids = unique(gene_ids)
stopifnot(rownames(Z) == (rownames(gene_ids)))

outputfile_path = file.path(parent_folder, "results", paste0(experiment , "_Z_threshold.txt"))
write.table(Z, file = outputfile_path, sep = '\t')

# Plots for the final report:
figure4 = file.path(parent_folder, "figures", paste0(experiment, "sd_histogram.png"))
png(figure4)
ggplot()+
  geom_histogram(aes(log(raw_sd)), binwidth = 0.1, col ="black", fill = "white")+
  geom_vline(xintercept =  log(sd_quantile), linetype = "dashed", col = 'blue')+
  labs(title = "Est. counts standard deviation threshold",
       caption = "Histogram of the standard deviation of the raw counts. The blue line represents the threshold used for filtering in step 04.")+
  xlab("Standard deviation (log scale)")+
  ylab("counts")
dev.off()

figure5 = file.path(parent_folder, "figures", paste0(experiment, "mean_histogram.png"))
png(figure5)
ggplot()+
  geom_histogram(aes(log(raw_means)), binwidth = 0.1, col ="black", fill = "white")+
  geom_vline(xintercept =  log(sd_quantile), linetype = "dashed", col = 'blue')+
  labs(title = "Est. counts means threshold",
       caption = "Histogram of the means of the raw counts. The blue line represents the threshold used for filtering in step 04.")+
  xlab("Mean (log scale)")+
  ylab("counts")
dev.off()

# Save the file paths into the json copy for the final report:
path_2_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy <- read_json(path_2_json_copy)
json_copy$path_2_results$Z_threshold = as.character(outputfile_path)
json_copy$figures$sd_histogram = as.character(figure4)
json_copy$figures$mean_histogram = as.character(figure5)
write_json(json_copy, path_2_json_copy, auto_unbox = TRUE)
