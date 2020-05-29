## A script that performs linear regression on log10 value of % Eigenvalues vs component number
## for 1->N, 2->N, until (N-2)->N and finds the meaningful PCs with a maximum threshold on the
## R-squared value for each regression. N max = variable in JSON. Default = 9.
## It adds the coordinate of individual observations for each sample on each meaningful
## PC to the design file as new columns (PC1, PC2...PCN where N = last meaningful PC)

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]
# **********************************************************************

## Load in the necessary libraries:
print("*** Loading libraries ***")
options(stringsAsFactors = FALSE)
options(bitmapType='cairo')
library(genefilter)
library(jsonlite)
library(readr)
library(ggplot2)

# Read in input files:
# JSON input file with SD and AVG thresholds
print("*** Reading the input files ***")
json = read_json(path2_json_file)
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = file.path(parent_folder, "results", paste0(experiment, "_design.txt"))
path_2_eigenvalues = file.path(parent_folder, "results", paste0(experiment, "_pca_eigenvalues.txt"))
path_2_pca = file.path(parent_folder, "results", paste0(experiment, "_pca_object.rds"))
path_2_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy <- read_json(path_2_json_copy)

# Extract the R-squared value from the JSON. Default R-squared threshold = 0.95.
print("*** Extracting adjusted R-squared threshold value from the JSON ***")
if (!is.numeric(json$input_variables$R_squared_threshold)){
  max_Rsqured = 0.95
} else if (json$input_variables$R_squared_threshold > 1){
  max_Rsqured = 0.95
} else if (json$input_variables$R_squared_threshold <= 0){
  max_Rsqured = 0.95
} else {max_Rsqured = json$input_variables$R_squared_threshold}

# Extract the max number of PC for regression. Default = 10.
print("*** Extracting the max number of PC to be used for regression ***")
if (!is.numeric(json$input_variables$max_number_PC_regression)){
  max_PC_regression = 10
} else if(json$input_variables$max_number_PC_regression<1){
  max_PC_regression = 10
} else {max_PC_regression = json$input_variables$max_number_PC_regression}

# Load files
design = read.table(path2_design, sep = "\t", header = TRUE, row.names = 1)
pca_eigenvalue = read.table(path_2_eigenvalues, sep = "\t", header = TRUE, row.names = 1)
pca = read_rds(path_2_pca)

# **************** Start of the program **********************

options(scipen = 999) #to avoid display in scientific notation

# Visualize percent variation and decide which PCs matter
pca_eigenvalue$dimension = 1:nrow(pca_eigenvalue)
pca_variation = round(pca_eigenvalue$variance.percent, 3)
# convert to log10
pca_var_log = log10(pca_variation)

# Create an empty table to save coefficients
number_PC = nrow(pca_eigenvalue)
res = data.frame(model_num  = rep(0, number_PC-3),
                 slope = rep(0,number_PC-3),
                 intercept = rep(0, number_PC-3),
                 R_squared = rep(0, number_PC-3),
                 adj_R_squared = rep(0, number_PC-3))

# Performing linear regression to find meaningful components
# Warning: doing up to (N-2)->N or up to JSON parameter for mac PC number (default = 10)
print("*** Performing linear regression of log10 eigenvalues vs. PC number ***")
for (i in 1:(number_PC-3)){
  if (i>max_PC_regression){
    break
  }
  linear = lm(pca_var_log[i:(number_PC-2)] ~ pca_eigenvalue$dimension[i:(number_PC-2)])
  res$model_num[i] = i
  res$intercept[i] = coef(linear)[1]
  res$slope[i] = coef(linear)[2]
  res$R_squared[i] = summary(linear)$r.squared
  res$adj_R_squared[i] = summary(linear)$adj.r.squared
}

### Save the regression table
output_pc_eigen = file.path(parent_folder, "results", paste0(experiment, "_regression_pc_eigen.txt"))
write.table(res, file = output_pc_eigen, sep = '\t')
json_copy$path_2_results$pc_vs_eigen = as.character(output_pc_eigen)

# Find the significant PCs according to a max R_squared threshold

# Establish the cutoff line and save that line as last_meaningful:

for (i in 1:((nrow(res))-1)){
  if (res$adj_R_squared[i] > max_Rsqured){
    break()
  } 
  last_meaningful = i
}

if (!exists("last_meaningful")){
  print("Error: The program could not identify any meaningful components")
  print("This is due to the adjusted R_squared threshold for the regression between Eigenvalue and PC number")
  stop()
}

print("*** Adding the meaningful PCs coordinates to a copy of the design file ***")
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

print("*** Generating plots for the final report ***")
# Plots for the final report:

pca_var_log = as.data.frame(pca_var_log)
pca_var_log$dimensions = 1:nrow(pca_var_log)

figure9 = file.path(parent_folder, "figures", paste0(experiment, "_log10scree_plot.png"))
png(figure9)
ggplot()+
  geom_point(aes(x = pca_var_log$dimensions, y = pca_var_log$pca_var_log))+
  xlab("PC number")+
  ylab("Eigenvalue log10")+
  scale_x_continuous(breaks=c(1:nrow(pca_var_log)))+
  ggtitle("Log 10 of the Eigenvalues vs PC number")
dev.off()

# create a color palette
colfunc <- colorRampPalette(c("blue",
                              "violet",
                              "red",
                              "orange",
                              "yellow",
                              "green",
                              "brown",
                              "black"))

figure10 = file.path(parent_folder, "figures", paste0(experiment, "_regression_plot.png"))
png(figure10)
colors = colfunc(nrow(res))
plot(pca_var_log$dimensions, pca_var_log$pca_var_log,
     xlab = "PC number", ylab = "Eigenvalue log10",
     main = "log10 of eigenvalues with the regression lines")
for (i in 1:(nrow(res))){
  abline(a = res$intercept[i], b = res$slope[i], col = colors[i])
  text(x=number_PC-2, y=(i * 0.1)+0.6, labels=paste0("model # ", i, "->", "N-3"), col = colors[i])
}
dev.off()

### Generate a loading scores table  only for meaningful PCs ##
loadings_meaningful = pca$rotation[,1:last_meaningful]

### Save the loadings for meaningful PC into a file ###
output_loadings_meaningful = file.path(parent_folder, "results", paste0(experiment, "_meaningful_pc_loading_scores.txt"))
write.table(loadings_meaningful, file = output_loadings_meaningful, sep = '\t')



# Updating the json copy
json_copy$path_2_results$design_meaningful = as.character(output_design_meaningful)
json_copy$path_2_results$meaningful_loading_scores = as.character(output_loadings_meaningful)
json_copy$figures$scree_plot_log10 = as.character(figure9)
json_copy$figures$regression_plot = as.character(figure10)
write_json(json_copy, path_2_json_copy, auto_unbox = TRUE)

