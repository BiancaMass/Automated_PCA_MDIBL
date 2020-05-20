# A script that performs Z-transformation on the count matrix
# Z = (x-mean) / sd
# where A and SD are the average and standard deviations 
# of expression for that gene across all samples.

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# **********************************************************************
# Hard coded to test
path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

print("*** Loading libraries ***")
options(stringsAsFactors = FALSE)
options(bitmapType='cairo')
library(genefilter)
library(jsonlite)
library(ggplot2)

# Load the necessary libraries
print("*** Reading the input files ***")
# Reading the json file with the file paths
json = read_json(path2_json_file)

# File paths to parent folder, and input file (normalized matrix from step_02.R i.e. rld or vsd matrix)
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"

if (file.exists(file.path(parent_folder, "results", paste0(experiment,"_rld_normalized.txt")))){
  input_matrix = file.path(parent_folder, "results", paste0(experiment,"_rld_normalized.txt"))
}

if (file.exists(file.path(parent_folder, "results", paste0(experiment,"_vst_normalized.txt")))){
  input_matrix = file.path(parent_folder, "results", paste0(experiment,"_vst_normalized.txt"))
}

# Read the input matrix
matrix_norm = read.table(input_matrix, sep = '\t', header = TRUE,  row.names = 1)

print("*** Calculate the mean and the standard deviaton for the rlog/vsd normalized matrix, by row")
# Calculate the mean and standard deviation for the rlog/vsd normalized matrix, by row
# (i.e. for a gene across all samples)
mn = apply(matrix_norm, 1, mean, na.rm = TRUE)
stdev = apply(matrix_norm, 1, sd, na.rm = TRUE)

print("*** Apply Z-transformation ***")
# Apply a Z-trasnformation, so that gene means = 0, gene sd = 1
Z = (matrix_norm - mn) / stdev

# Save a Z table with mn and stdev (before Z norm, after rlog/vst) columns:
Z_ms = cbind(Z, mn)
Z_ms = cbind(Z_ms, stdev)

print("*** Saving the output files to the results folder ***")
# Save the normalized matrix and the normalized matrix with mean and sd columns added to the end
output_Z = file.path(parent_folder, "results", paste0(experiment, "_Z_normalized.txt"))
write.table(Z, file = output_Z, sep = '\t')

output_Z_ms = file.path(parent_folder, "results", paste0(experiment, "_Z_mean_stdev.txt"))
write.table(Z_ms, file = output_Z_ms, sep = '\t')

## Generate plots for the report
figure1 = file.path(parent_folder, "figures", paste0(experiment, "_rlog_vsd_mean_sd.png"))
png(figure1)
ggplot()+
  geom_point(aes(Z_ms$mn, Z_ms$stdev))+
  ggtitle("Mean vs standard deviation after rld() or vsd() normalization")+
  theme(axis.text.x = element_text(angle = 90))+
  scale_x_continuous(labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(labels = function(x) format(x, scientific = TRUE))+
  xlab("Mean") + ylab("Standard deviation")
dev.off()

figure2 = file.path(parent_folder, "figures", paste0(experiment, "Z_mean_sd.png"))
png(figure2)
ggplot()+
  geom_point(aes(rowMeans(Z), genefilter::rowSds(Z)))+
  ggtitle("Mean vs standard deviation after Z normalization")+
  theme(axis.text.x = element_text(angle = 90))+
  scale_x_continuous(labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(labels = function(x) format(x, scientific = TRUE))+
  xlab("Mean") +  ylab("Standard deviation")
dev.off()


# Update the json copy used for report generation:
path_2_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy <- read_json(path_2_json_copy)
json_copy$path_2_results$Z_table = as.character(output_Z)
json_copy$path_2_results$Z_with_mean_sd = as.character(output_Z_ms)
json_copy$figures$rld_mean_sd = as.character(figure1)
json_copy$figures$Z_mean_sd = as.character(figure2)
write_json(json_copy, path_2_json_copy, auto_unbox = TRUE)


