# A script that automatically generates a report of the pipeline

args = base::commandArgs(trailingOnly = TRUE)
print(args)
path2_json_file = args[1]

# Hard coded to test
# path2_json_file = "/home/mbianca/Downloads/28_17/data/pasilla_json.json"

library(knitr)
library(jsonlite)
library(rmarkdown)

json = read_json(path2_json_file)

parent_folder = json$folders$parent_folder
experiment = json$input_files$experiment_name
report_file = file.path(parent_folder, "scripts", "final_report.Rmd")
output_directory = file.path(parent_folder, "report")
output_name = paste0(experiment, "_results")

# pandoc_location = Sys.getenv("RSTUDIO_PANDOC")
# pandoc_version()
# Sys.getenv("RSTUDIO_PANDOC")
# Sys.setenv(RSTUDIO_PANDOC="/usr/lib/rstudio-server/bin/pandoc")

rmarkdown::render(report_file,
                  output_format = c("html_document"),
                  output_file = output_name,
                  output_dir = output_directory,
                  params = list(
                    json = path2_json_file,
                    set_subtitle = paste("Experiment:", experiment)))

