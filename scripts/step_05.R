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

# Read in input files:
# JSON input file with SD and AVG thresholds
print("*** Reading the input files ***")
json = read_json(path2_json_file)
parent_folder = json[[1]][["folders"]][["parent_folder"]]
experiment = json[[1]][["input_files"]][["experiment_name"]]
path2_design = file.path(parent_folder, "results", paste0(experiment, "_design.txt"))
path2_count = file.path(parent_folder, "results", paste0(experiment , "_Z_threshold.txt"))

# Read in the filtered count matrix and the design file
filt_count = as.matrix(read.table(path2_count, sep = "\t", header = TRUE, row.names = 1))
design = read.table(path2_design, sep = "\t", header = TRUE, row.names = 1)
# !!!!! Assumes treatment is column 3 !!!!
pca_variable = colnames(design)[3]


# **************** Start of the program **********************
print("*** Start of the program ***")
# Check that the count matrix has been normalized
mn = apply(filt_count, 1, mean)
stdev = apply(filt_count, 1, sd)

if (mean(mn) < -(0.0001) | mean(mn) > 0.0001){
  print("The count matrix is not normalized. Mean of means != 0")
  stop()
}

if (mean(stdev) != 1){
  print("Not all standard deviations of the normalized matrix == 1")
}

## Perform PCA on the samples.

print("***Performing PCA. This can take a while.***")
cols = ncol(filt_count)
count_transposed <- t(filt_count)
pca = prcomp(count_transposed)
plot(pca$x[,1], pca$x[,2])
plot(pca$x[,2], pca$x[,3])
pcavar <- pca$sdev^2
pca.var.per <- round(pcavar/sum(pcavar)*100,1)
barplot(pca.var.per, main = 'Scree Plot', xlab= "Principal Component",
        ylab = "Percent Variation")

# Format the data the way ggplot2 likes it:
pca.data <- data.frame(Sample = rownames(pca$x),
                       PC1 = pca$x[,1],
                       PC2 = pca$x[,2],
                       PC3 = pca$x[,3],
                       PC4 = pca$x[,4],
                       PC5 = pca$x[,5],
                       PC6 = pca$x[,6])

design$Sample = row.names(design)

pca.data = dplyr::left_join(pca.data, design, by = "Sample")

ggplot(data = pca.data, aes(x = PC1, y = PC2, label = Sample,
                            color = treatment)) +
  geom_text() +
  xlab(paste("PC1: ", pca.var.per[1], "%", sep = ""))+
  ylab(paste("PC2: ", pca.var.per[2], "%", sep = ""))+
  theme_bw() + 
  ggtitle("My PCA plot")


ggplot(data = pca.data, aes(x = PC3, y = PC4, label = Sample,
                            color = treatment)) +
  geom_text() +
  xlab(paste("PC3: ", pca.var.per[3], "%", sep = ""))+
  ylab(paste("PC4: ", pca.var.per[4], "%", sep = ""))+
  theme_bw() + 
  ggtitle("My PCA plot")

# Use the loading scores to determine which genes have the 
# largest effect on where samples are plotted in the PCA plot.

# Genes that push samples to the right in a PC plot will have
# large positive loading score values.
# Genes that push them to the left will have 
# a large negative value.

# For PC1:
loading_scores <- pca$rotation[,1]
gene.scores <- abs(loading_scores)
gene.scores.ranked <- sort(gene.scores, decreasing = TRUE)
top_10_genes <- names(gene.scores.ranked[1:10])
top_10_genes

# Check which have positive which have negative lod scores:
# Still within PC1
pca$rotation[top_10_genes,1]









# ******************* Script 06. Find the meaningful components
# Right now, to find meaningful components I fit a Pearson correlation
# between the design column taken as a variable (e.g. treatment)
# and each PCA.

# Chek that experiment label i the design file are the same (and same order)
# than experiment labels of the pca loadings
stopifnot(rownames(pca) == rownames(design))

# Creating an empty data set to store my linear model results.
results = data.frame(pc_num  = rep(0, cols),
                     cor = rep(0,cols),
                     pv  = rep(0,cols))

pca_variable_from_design = "treatment"
variable_pca = design[, pca_variable_from_design]
categorical_variable = as.numeric(as.factor(variable_pca))

for (i in 1:ncol(pca$x)){
  mod = cor.test(categorical_variable, pca$x[,i])
  #linear = lm(load_pc[,i] ~ design$treatment)
  results$cor[i] = mod$estimate
  results$pv[i] = mod$p.value
  results$pc_num[i] = i
}

labels=list(unique(variable_pca)[1], unique(variable_pca)[2])

# Insert in the report

for (i in 1:ncol(pca$x)){
  x <- categorical_variable
  y <- pca$x[,i]
  plot(x, y, main = c("PC", i),
       xlab = "Samples", ylab = "PC loading",
       pch = 1, col = categorical_variable, frame = FALSE)
  abline(lm(pca$x[,i] ~ categorical_variable), col = "blue")
  legend("top", legend = c(unique(variable_pca)[1], unique(variable_pca)[2]),
         pch = 1, col = 1:2)
}






#citation("pcaMethods")

