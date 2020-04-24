## A script that performs PCA on a normalized count matrix.

args = base::commandArgs(trailingOnly = TRUE)
print(args)

path2_json_file = args[1]

# **********************************************************************
# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

## Load in the necessary libraries:
options(stringsAsFactors = FALSE) 
library(pcaMethods)
library(Gviz)
library(forestmangr)
library(genefilter)
library(jsonlite)
library(ggplot2)
library(dplyr)
library(factoextra)
library(readr)

#### Read in input files ###
# JSON input file with SD and AVG thresholds
print("*** Reading the input files ***")
json = read_json(path2_json_file)
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = file.path(parent_folder, "results", paste0(experiment, "_design.txt"))
path2_count = file.path(parent_folder, "results", paste0(experiment , "_Z_threshold.txt"))

### Read in the filtered count matrix and the design file ###
filt_count = as.matrix(read.table(path2_count, sep = "\t", header = TRUE, row.names = 1))
design = read.table(path2_design, sep = "\t", header = TRUE, row.names = 1)
# !!!!! Assumes treatment is column 3 !!!!
# pca_variable = colnames(design)[3]


# **************** Start of the program **********************
print("*** Start of the program ***")

### Check that the count matrix has been normalized ###
mn = apply(filt_count, 1, mean)
stdev = apply(filt_count, 1, sd)

if (mean(mn) < -(0.0001) | mean(mn) > 0.0001){
  print("The count matrix is not normalized. Mean of means != 0")
  stop()
}

if (mean(stdev) != 1){
  print("Not all standard deviations of the normalized matrix == 1")
}

### Perform PCA on the samples ###

print("***Performing PCA. This can take a while.***")
cols = ncol(filt_count)
pca = prcomp(t(filt_count), scale = TRUE)
# par(mfrow=c(1,2))
# plot(pca$x[,1], pca$x[,2])
# plot(pca$x[,2], pca$x[,3])
# Scree plot generation:
pcavar <- pca$sdev^2
pca.var.per <- round(pcavar/sum(pcavar)*100,1)
# barplot(pca.var.per, main = 'Scree Plot', xlab= "Principal Component #",
#         ylab = "Percent Variation")
#fviz_eig(pca) # another way to visualize percentage contribution

### Ggplot plot for the report ###
# Format the data the way ggplot2 likes it:
# pca.data <- data.frame(Sample = rownames(pca$x),
#                        PC1 = pca$x[,1],
#                        PC2 = pca$x[,2],
#                        PC3 = pca$x[,3],
#                        PC4 = pca$x[,4],
#                        PC5 = pca$x[,5],
#                        PC6 = pca$x[,6])
# 
# design$Sample = row.names(design)
# pca.data = dplyr::left_join(pca.data, design, by = "Sample")
# ggplot(data = pca.data, aes(x = PC1, y = PC2, label = Sample,
#                             color = treatment)) +
#   geom_text() +
#   xlab(paste("PC1: ", pca.var.per[1], "%", sep = ""))+
#   ylab(paste("PC2: ", pca.var.per[2], "%", sep = ""))+
#   theme_bw() +
#   ggtitle(paste("PC1 vs PC2", "| Experiment: ", experiment))

### Generate a loading scores table ##
loadings = pca$rotation

### Save the loadings for each PC into a file ###
output_loadings = file.path(parent_folder, "results", paste0(experiment, "_pca_loading_scores.txt"))
write.table(loadings, file = output_loadings, sep = '\t')

#Reminder: loading scores are the proportion of how much each gene contributes
# to each pricipal component (where samples are plotted in the PCA plot).
# A large positive loading score will push sample to the right.
# A large negative loading score will push sample to the left.
# The higher the loading score, the more that gene was responsible for that PC.

# Find the genes with the highest loading scores for each component
# (therefore the ones that contributed the most to determine the
# direction of that component):

# For PC1:
gene.scores = abs(loadings[,1])
gene.scores.ranked = sort(gene.scores, decreasing = TRUE)
top_20_genes = names(gene.scores.ranked[1:20])
pca$rotation[top_20_genes,1]

# Save the eigenvalues
pca_eigenvalue=get_eig(pca)
output_eigenvalues = file.path(parent_folder, "results", paste0(experiment, "_pca_eigenvalues.txt"))
write.table(pca_eigenvalue, file = output_eigenvalues, sep = '\t')

# Save the pca object
output_pca = file.path(parent_folder, "results", paste0(experiment, "_pca_object.rds"))
write_rds(pca, output_pca)


