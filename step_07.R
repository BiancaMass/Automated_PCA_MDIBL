## A script that for each meaningful principal component regresses on the design equation variables.

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# **********************************************************************
## Load in the necessary libraries:
options(stringsAsFactors = FALSE)
options(bitmapType='cairo')
library(jsonlite)
library(readr)
library(ggplot2)
library(stringr)

# Read in input files:
print("*** Reading the input files ***")
json = read_json(path2_json_file)
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = file.path(parent_folder, "results", paste0(experiment, "_design_meaningful.txt"))
path_2_pca = file.path(parent_folder, "results", paste0(experiment, "_pca_object.rds"))
path_2_json_copy = file.path(parent_folder, "results", paste0(experiment, "_json_copy.json"))
json_copy = read_json(path_2_json_copy)

# Load files
design = read.table(path2_design, sep = "\t", header = TRUE, row.names = 1)
pca = read_rds(path_2_pca)

# Chek 1:1 correspondence b/w experiment labels in the design file
# and sample values in the PCs.
stopifnot(rownames(pca$x) == rownames(design))

# Creating an empty data set to store my cor.model results.
# Create as many datasets as there are design formulas.

# Create a list of the design formulas from the JSON file
design_formulas = c(rep(0, length(json$design_variables)))

for (i in 1:(length(json$design_variables))){
  if (str_length(json$design_variables[[i]]) > 0){
    design_formulas[i] = json$design_variables[[i]]
  }else if (str_length(json$design_variables[[i]]) <= 0){
    design_formulas = design_formulas[-i]
  }
}

# Extract the number of meaningful PC from the design file:
columns = grep("PC", colnames(design))
number_PC = length(columns)

print("*** Performing the correlation test and generating plots ***")
### A loop that performs the following operations: ###
# extract the column from the design file for each design formula (e.g. column "site")
# performs a cor.test between each design formula (e.g. "sex": "M" or "F") and each meaningful PC
# saves results to a table
# plot the correlations and saves the plots in the figures folder (for the automated report)

# main loop across the design formulas:
for (formula in 1:length(design_formulas)){
  # extract the design formula variables from design file
  variable_pca = design[, design_formulas[formula]]
  # convert them into numeric to fit the model
  categorical_variable = as.numeric(as.factor(variable_pca))
  # temporary data set to store model results and then rename:
  results = data.frame(pc_num  = rep(1:number_PC),
                       cor = rep(0, number_PC),
                       pv  = rep(0, number_PC))
  # loop across all the meaningful PCs:
  for (j in 1:number_PC){
    # fit the correlation test between current PC (j) and current formula (formula)
    mod = cor.test(categorical_variable, pca$x[, j])
    # assign results to the right column and row in the results data set
    results$cor[j] = mod$estimate
    results$pv[j] = mod$p.value
    # rename the results data set appropriately
    assign(paste0("results_", design_formulas[formula]), results)
    
    # save the results table
    path_2_correlation = file.path(parent_folder,
                                   "results",
                                   paste0(experiment, "_", design_formulas[formula], "_correlation.txt"))
    write.table(results, file = path_2_correlation, sep = '\t')
    
    # save the path to the table into the json copy
    json_copy$path_2_results$correlation_table[formula] = as.character(path_2_correlation)
  }
  ### Create plots for the automated report ###
  #
  labels=list(unique(variable_pca)[1], unique(variable_pca)[2])
  # a file path to store the figure:
  figurex = file.path(parent_folder, "figures", paste0(experiment, "_cor_plot_", formula, ".png"))
  png(figurex)
  par(mfrow = c(1, number_PC))
  for (i in 1:number_PC){
    x <- categorical_variable
    y <- pca$x[,i]
    plot(x, y, main = c("PC", i),
         xlab = "Samples", ylab = "PC value",
         pch = 1, col = categorical_variable, frame = FALSE)
    abline(lm(pca$x[,i] ~ categorical_variable), col = "blue")
    legend("top", legend = c(unique(variable_pca)[1], unique(variable_pca)[2]),
           pch = 1, col = 1:2)
    mtext(paste("correlation results for '", as.character(design_formulas[formula]), "' variable"),
          side = 3, line = -1, outer = TRUE)
  }
  dev.off()
  # Save the figure path into the json_copy:
  json_copy$figures$scree_plot_cor[formula] = as.character(figurex)
}


# save the updated json copy 
write_json(json_copy, path_2_json_copy, auto_unbox = TRUE)


# Following steps to come:
# Perform a regression with interaction terms
# Filter for p-value and correlation coefficient to establish whether the meaningful PCs have strong correlation
# with the design equations variables


### Find if meaningful PCs have association with the experimental design
### Boundaries for p-value and correlation coefficient
## Find the principal component that explain the design equation
## Standards chosen: p-value = 0.5
## abs(slope) >= 0.3

# significant_results = data.frame(pc_num  = rep(NA, number_PC),
#                                  cor = rep(NA, number_PC),
#                                  pv  = rep(NA, number_PC))
# 
# 
# for (i in 1:nrow(results)){
#   if((results$pv)[i] <= 0.06 & (abs((results$cor)[i]) >= 0.3)) {
#     significant_results[i, ] = results[i, ]
#   }
# }
# 
# output_sig_res = file.path(parent_folder, "results", paste0(experiment, "_significant_PC_vs_designformula.txt"))
# write.table(significant_results, file = output_sig_res, sep = '\t')


