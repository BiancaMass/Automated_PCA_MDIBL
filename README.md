# Automated_PCA_MDIBL
A repository containing the steps for an automated PCA pipeline on a gene estimated counts matrix. Runs on R scripts through bash. Takes JSON file as input.

1. Requirements
2. Operating instructions
3. Provided files list
4. Copyright and licensing 
5. Contact information
6. Known bugs
7. Credits and acknowledgements
8. Changelog

## 1. Requirements
- Libraries
- R version

## 2. Operating instructions

In order to run:

1. Create a folder (parent folder), containing the following subfolders:
- scripts
- data

2. Save your data (estimated count matrices and design files) in the data folder, together with the json input file.

3. Save the scripts in the scripts folder

4. Open the bash script "bash_automated_pca.sh"

5. Change the following variables in the bash script:
  - PARENT_DIR=~/path/2/your/parent/folder
  - JSON_FILE_NAME=name_of_your_json.json
  
 5. Change the variables in the json file to fit your file paths and desired parameters (see the README  inside the data folder).
  
 6. In the terminal, cd to the parent_folder/scripts and run the following command:
 bash bash_automated_pca.sh
 
## 3. Provided files list
## 4. Copyright and licensing 
## 5. Contact information
## 6. Known bugs
## 7. Credits and acknowledgements
## 8. Changelog
