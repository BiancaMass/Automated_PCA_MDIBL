# Data Repository

This README file is divided into three sections:
  1. A description of the required format for the design file
  1. A description of the required format for the estimated counts file
  1. A description of the required format for the JSON file


## 1. Design file


## 2. Estimated count matrix


## 3. JSON
The json file contains a list of variables in the form of file paths or numbers. File paths will need to match the file paths of your data files. You can change the numeric parameters to fit your analysis needs. If you will not change them, the pipeline will use default parameters. Follows a list of the variables and their description.

{
  "input_files": {
    "infile1":"path/to/design_file.txt",
    "infile2":"path/to/estcountsmatrix.txt",
    "experiment_name": "name_of_your_experiment"
  },
