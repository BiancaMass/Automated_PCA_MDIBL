# A script that automatically generates a report of the pipeline


path2_json_file = "~/Documents/senior_project/automated_pca/data/pipeline_input_file.json"

library(knitr)
library(jsonlite)
library(rmarkdown)

json = read_json(path2_json_file)

parent_folder = json$folders$parent_folder
experiment = json$input_files$experiment_name
report_file = file.path(parent_folder, "scripts", "final_report.Rmd")
output_directory = file.path(parent_folder, "report")
output_name = paste0(experiment, "_results")

rmarkdown::render(report_file,
                  output_format = "html_document",
                  output_file = output_name,
                  output_dir = output_directory)






knit(report_file,
     output = output_path,
     tangle = FALSE,
     text = NULL,
     quiet = FALSE,
     envir = parent.frame(),
     encoding = "UTF-8"
     )
