## A script that performs linear regression on Eigenvalues vs component number
## for 1->N, 2->N, until (N-2)->N and finds the meaningful PCs by setting
## a cutoff for slope change = 0.5
## It adds the coordinate of individual observations for each sample on each meaningful
## PC to the design file as new columns (PC1, PC2...PCN where N = last meaningful PC)

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
library(dplyr)
library(factoextra)
library(readr)
library(latticeExtra)
#library(broom)

# Read in input files:
# JSON input file with SD and AVG thresholds
print("*** Reading the input files ***")
json = read_json(path2_json_file)
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = file.path(parent_folder, "results", paste0(experiment, "_design.txt"))
path_2_eigenvalues = file.path(parent_folder, "results", paste0(experiment, "_pca_eigenvalues.txt"))
path_2_pca = file.path(parent_folder, "results", paste0(experiment, "_pca_object.rds"))

# Load files
design = read.table(path2_design, sep = "\t", header = TRUE, row.names = 1)
pca_eigenvalue = read.table(path_2_eigenvalues, sep = "\t", header = TRUE, row.names = 1)
pca = read_rds(path_2_pca)

# **************** Start of the program **********************

#par(mfrow = c(1,1))
# Visualize percent variation and decide which PCs matter
pca_eigenvalue$dimension = 1:nrow(pca_eigenvalue)
options(scipen = 999) #to avoid display in scientific notation
pca_variation = round(pca_eigenvalue$variance.percent, 3)
# convert to log10
pca_var_log = log10(pca_variation)
plot(pca_variation)
plot(pca_var_log)

# Create an empty table to save coefficients
number_PC = nrow(pca_eigenvalue)
res = data.frame(model_num  = rep(0, number_PC-3),
                 slope = rep(0,number_PC-3),
                 intercept = rep(0, number_PC-3),
                 R_squared = rep(0, number_PC-3),
                 adj_R_squared = rep(0, number_PC-3))

### Find meaningful components ###

# Performing linear regression on the log10 of the % Eigenvalues vs component number for 1->N, 2->N, until (N-3)->N
# Note: there is so substantial difference in doing it on raw Eigenvaues vs %, but percentage is easier to read.
# Warning: doing up to (N-3)->N or up to 10 PCs

# add a threshold for max 10 PCs (as a variable in the JSON)
# to the table add R^2 and a normalized R^2 (divided by number_PC-N)

for (i in 1:(number_PC-3)){
  linear = lm(pca_var_log[i:(number_PC-2)] ~ pca_eigenvalue$dimension[i:(number_PC-2)])
  res$model_num[i] = i
  res$intercept[i] = coef(linear)[1]
  res$slope[i] = coef(linear)[2]
  res$R_squared[i] = summary(linear)$r.squared
  res$adj_R_squared[i] = summary(linear)$adj.r.squared
}
# visualize the correlations:
colfunc <- colorRampPalette(c("blue4",
                              "deepskyblue",
                              "darkolivegreen1",
                              "darkgreen",
                              "red"))
colors = colfunc(nrow(res))
plot(pca_var_log)
for (i in 1:(nrow(res))){
  abline(a = res$intercept[i], b = res$slope[i], col = colors[i])
  text(x=number_PC-2, y=(i * 0.1)+0.6, labels=paste0("model # ", i, "->", "N-3"), col = colors[i])
}


#to gt the p.value (which I do not think I will need)
#glance(linear)$p.value

# Find the significant PCs
# I am arbitrarily deciding to set a slope change greater than 50% as a cutoff

for (i in 1:(nrow(res)-1)){
  percent_change = (abs((res$slope[i]-res$slope[i+1])))/abs(res$slope[i])
  #Stop the loop when the percent change in slope is more than 50%
  if (percent_change > 0.5){
    break
  }
}
# Take the last iteration through the loop to set the cut off point for meaningful PCs.
last_meaningful = i

# add the meaningful components values to the design file:

design_meaningful_PC = design

for (i in 1:last_meaningful){
  variable = paste0("PC", i)
  design_meaningful_PC = cbind(design_meaningful_PC, variable = pca$x[,i])
  # assign the right column name to the column just created:
  colnames(design_meaningful_PC)[length(colnames(design_meaningful_PC))] <- variable
}

# Save the copy of the design file that includes all “meaningful” component values as new columns:

output_design_meaningful = file.path(parent_folder, "results", paste0(experiment, "_design_meaningful.txt"))
write.table(design_meaningful_PC, file = output_design_meaningful, sep = '\t')




# Outputs:

# A design file with the meaningful PCs.








