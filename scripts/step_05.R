## A script that performs PCA on a normalized count matrix.

args = base::commandArgs(trailingOnly = TRUE)
print(args)

path2_json_file = args[1]

# **********************************************************************
# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

## Load in the necessary libraries:
options(stringsAsFactors = FALSE)
options(bitmapType='cairo')
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
# for scree plot generation:
pcavar <- pca$sdev^2
per.pcavar = round(pcavar/sum(pcavar)*100,1)

### Generate a loading scores table ##
loadings = pca$rotation

### Save the loadings for each PC into a file ###
output_loadings = file.path(parent_folder, "results", paste0(experiment, "_pca_loading_scores.txt"))
write.table(loadings, file = output_loadings, sep = '\t')

# Save the eigenvalues
pca_eigenvalue=get_eig(pca)
output_eigenvalues = file.path(parent_folder, "results", paste0(experiment, "_pca_eigenvalues.txt"))
write.table(pca_eigenvalue, file = output_eigenvalues, sep = '\t')

# Save the pca object
output_pca = file.path(parent_folder, "results", paste0(experiment, "_pca_object.rds"))
write_rds(pca, output_pca)



# Figures for the report

figure6 = file.path(parent_folder, "figures", paste0(experiment, "scree_plot.png"))
png(figure6)
fviz_eig(pca) # another way to visualize percentage contribution
dev.off()

# figure of PC1 vs PC2
# Format the data the way ggplot2 likes it:
pca_data <- matrix(ncol= ncol(pca$x)+1, nrow = nrow(pca$x))
pca_data[,1] = rownames(pca$x)
for (columns in 1:ncol(pca$x)){
  pca_data[,columns+1] = pca$x[,columns]
}

pca_data = as.data.frame(pca_data)
names(pca_data)[1] = "Sample"
for (col_names in 2:ncol(pca_data)){
  names(pca_data)[col_names] = paste0("PC", col_names-1)
}

design$Sample = row.names(design)
pca_data = dplyr::left_join(pca_data, design, by = "Sample")

figure7 = file.path(parent_folder, "figures", paste0(experiment, "PC1_PC2.png"))
png(figure7)
ggplot(data = pca_data, aes(x = PC1, y = PC2, label = site,
                            color = treatment)) +
  geom_text() +
  xlab(paste("PC1: ", per.pcavar[1], "%", sep = ""))+
  ylab(paste("PC2: ", per.pcavar[2], "%", sep = ""))+
  theme_bw() +
  ggtitle(paste("PC1 vs PC2", "| Experiment: ", experiment))+
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank())
dev.off()

figure8 = file.path(parent_folder, "figures", paste0(experiment, "PC2_PC3.png"))
png(figure8)
ggplot(data = pca_data, aes(x = PC2, y = PC3, label = site,
                            color = treatment)) +
  geom_text() +
  xlab(paste("PC2: ", per.pcavar[2], "%", sep = ""))+
  ylab(paste("PC3: ", per.pcavar[3], "%", sep = ""))+
  theme_bw() +
  ggtitle(paste("PC2 vs PC3", "| Experiment: ", experiment))+
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank())
dev.off()



# Updating the json copy
path_2_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy <- read_json(path_2_json_copy)
json_copy$path_2_results$all_loading_scores = as.character(output_loadings)
json_copy$path_2_results$eigenvalues = as.character(output_eigenvalues)
json_copy$path_2_results$pca_object = as.character(output_pca)
json_copy$figures$scree_plot = as.character(figure6)
json_copy$figures$PC1_PC2 = as.character(figure7)
json_copy$figures$PC2_PC3 = as.character(figure8)
write_json(json_copy, path_2_json_copy, auto_unbox = TRUE)



# with log scale:
# log.pca.var.per <- log(round(pcavar/sum(pcavar)*100,1))
# barplot(log.pca.var.per, main = 'Scree Plot', xlab= "Principal Component #",
#         ylab = "Percent Variation", ylim = c(0.001,5))



















#Reminder: loading scores are the proportion of how much each gene contributes
# to each pricipal component (where samples are plotted in the PCA plot).
# A large positive loading score will push sample to the right.
# A large negative loading score will push sample to the left.
# The higher the loading score, the more that gene was responsible for that PC.

# Find the genes with the highest loading scores for each component
# (therefore the ones that contributed the most to determine the
# direction of that component):

# For PC1:
# gene.scores = abs(loadings[,1])
# gene.scores.ranked = sort(gene.scores, decreasing = TRUE)
# top_20_genes = names(gene.scores.ranked[1:20])
# pca$rotation[top_20_genes,1]
