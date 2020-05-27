# A script that normalizes the expression matrix using rlog() or vst() depending on matrix size.
# Cut-off: ncol count matrix <= 30 for rlog(), else vst().

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# **********************************************************************
# Load the necessary libraries
print("*** Loading libraries ***")
options(stringsAsFactors = FALSE)
options(bitmapType='cairo')
library(jsonlite)
library(forestmangr)
library(DESeq2)
library(genefilter)
library(stringr)
library(SparkR)
library(ggplot2)

# **********************************************************************

# Reading the json file with the file paths
print("*** Reading the input files ***")
json = read_json(path2_json_file)

# Extract the input file paths and variables from json
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = json$"input_files"$"infile1"
path2_counts = json$"input_files"$"infile2"
min_rawcounts_rowsum = json$input_variables$min_gene_tot_raw_count
min_mean = json$input_variables$min_count_mean

# Read in the design and estimated counts files
design = read.table(path2_design, header = TRUE, sep = "\t", row.names = 1)
counts = read.table(path2_counts, header = TRUE, sep = "\t", row.names = 1)

# Stop the program if there are negative counts in the matrix:

if (any(counts < 0 )) { print("*** Error: not all numbers in the count matrix are positive ***");
  stop()
}

print("*** Rounding the count matrix to integers ***")
# Round the count matrix, remove rowSums <= min_gene_tot_raw_counts (JSON), and filter for row with a mean above the
# mean threshold set in the JSON file
counts <- round_df(counts, digits = 0, rf = "round")
print("*** Filtering the count matrix accoring to the parameters set in the JSON input file")
counts = subset(counts, rowSums(counts)>min_rawcounts_rowsum)
counts = subset(counts, apply(counts, 1, mean) > min_mean)

# Check that the rounding worked:
if (sum(counts != apply(counts, 2, as.integer)) > 0) { print("Error: not all numbers in the rounded count matrix are integers");
  stop()
}

# Calculating mean and sd for each gene across all samples:
counts_mean = apply(counts, 1, mean, na.rm = TRUE)
counts_stdev = apply(counts, 1, sd, na.rm = TRUE)

# Save the matrix of gene means
output_mean = file.path(parent_folder, "results", paste0(experiment, "_genecounts_means.txt"))
write.table(counts_mean, file = output_mean, sep = '\t')
# Save the matrix of gene standard deviations
output_sd = file.path(parent_folder, "results", paste0(experiment, "_genecounts_sd.txt"))
write.table(counts_stdev, file = output_sd, sep = '\t')


# Construct the DeSeq data set to apply rlog()
print("*** Constructing the DESeq Data set ***")
print("*** Extracting the design formula from the JSON input file ***")

design_formula = as.formula(paste0(as.name(as.character(json$design_formula$design)), ""))

## Construct the DeSeq data set using the countdata (countmatrix) and coldata (sample information)
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = design,
                              design = design_formula
)


# Saving the paths to the report_json file (for the automated report generation)
path_2_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy <- read_json(path_2_json_copy)
json_copy$path_2_results$genecounts_means = as.character(output_mean)
json_copy$path_2_results$genecounts_sd = as.character(output_sd)


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
  json_copy$path_2_results$normalized_rld = as.character(output_matrix)
} else {
   vsd <- vst(dds, blind = FALSE)
   vsd_assay <- assay(vsd)
   output_matrix = file.path(parent_folder, "results", paste0(experiment,"_vst_normalized.txt"))
   write.table(vsd_assay, file = output_matrix, sep = '\t')
   json_copy$path_2_results$normalized_vst = as.character(output_matrix)
}

# Making a plot for the report:
figure1 = file.path(parent_folder, "figures", paste0(experiment, "raw_mean_sd.png"))
png(figure1)
ggplot()+
  geom_point(aes(rowMeans(counts), rowSds(counts)))+
  ggtitle("Mean vs standard deviation of the filtered count matrix", subtitle = "Before normalization")+
  theme(axis.text.x = element_text(angle = 90))+
  scale_x_continuous(labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(labels = function(x) format(x, scientific = TRUE))+
  xlab("Mean") +  ylab("Standard deviation")
dev.off()


json_copy$input_variables$design_formula = as.character(design_formula)
json_copy$figures$raw_mean_sd = as.character(figure1)
write_json(json_copy, path_2_json_copy, auto_unbox = TRUE)
