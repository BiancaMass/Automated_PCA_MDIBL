## A script that for each meaningful principal component regresses on the design equation variables.
## Standards to determine whether the component has an association with experimental design:
## p-value <= 0.06
## abs(slope) >= 0.3

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# **********************************************************************
# Hard coded to test
# path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

## Load in the necessary libraries:
options(stringsAsFactors = FALSE) 
library(jsonlite)
library(readr)

# Read in input files:
print("*** Reading the input files ***")
json = read_json(path2_json_file)
parent_folder = json$"folders"$"parent_folder"
experiment = json$"input_files"$"experiment_name"
path2_design = file.path(parent_folder, "results", paste0(experiment, "_design_meaningful.txt"))
path_2_pca = file.path(parent_folder, "results", paste0(experiment, "_pca_object.rds"))

# Load files
design = read.table(path2_design, sep = "\t", header = TRUE, row.names = 1)
pca = read_rds(path_2_pca)

# Chek 1:1 correspondence b/w experiment labels in the design file
# and sample values in the PCs.
stopifnot(rownames(pca$x) == rownames(design))

# Creating an empty data set to store my linear model results.
columns = grep("PC", colnames(design))
number_PC = length(columns)
results = data.frame(pc_num  = rep(1:number_PC),
                     cor = rep(0, number_PC),
                     pv  = rep(0, number_PC))

# hard coded
pca_variable_from_design = "treatment"
variable_pca = design[, pca_variable_from_design]
categorical_variable = as.numeric(as.factor(variable_pca))

for (i in 1:number_PC){
  mod = cor.test(categorical_variable, pca$x[,i])
  #linear = lm(load_pc[,i] ~ design$treatment)
  results$cor[i] = mod$estimate
  results$pv[i] = mod$p.value
}

labels=list(unique(variable_pca)[1], unique(variable_pca)[2])

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
}

## Find the principal component that explain the design equation
## Standards chosen: p-value = 0.5
## abs(slope) >= 0.3

significant_results = data.frame(pc_num  = rep(NA, number_PC),
                                 cor = rep(NA, number_PC),
                                 pv  = rep(NA, number_PC))


for (i in 1:nrow(results)){
  if((results$pv)[i] <= 0.06 & (abs((results$cor)[i]) >= 0.3)) {
    significant_results[i, ] = results[i, ]
  }
}

output_sig_res = file.path(parent_folder, "results", paste0(experiment, "_significant_PC_vs_designformula.txt"))
write.table(significant_results, file = output_sig_res, sep = '\t')

#citation("pcaMethods")

