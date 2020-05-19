# Automated_PCA_MDIBL
This repository contains a pipeline that identifies unexpected variables in an expression data matrix. It performs normalization on the count matrix, PC Analysis, and regression on the PCs vs experimental design. Once unexpected variables are identified, their PC coordinates are captured into a modified design file, to be used for downstream analysis as surrogates of e unexpected variable(s).


1. Input files
1. System requirements
2. Operating instructions
3. Provided files list
4. Copyright and licensing 
5. Contact information
6. Known bugs
7. Credits and acknowledgements
8. Changelog


## 1. Input files
- Estimated counts matrix.
  - Text file, tab separated.
  - Gene IDs are in rows, samples are in columns
  - First column is gene_id
  - Column names 2:N are the sample names

Example:

| gene_id	| sample1	| sample2	| sample3	| sample4	| sample5	| sample6	| sample7	| sample8 |
|---------|---------|---------|---------|---------|---------|---------|---------|---------|
|ENSMUSG00000000001	| 2 | 3 |	4	| 7	| 3	| 5	| 1	| 3 |
|ENSMUSG00000000037	| 10190 | 4432 | 2244 |	2797 | 2540	| 15565	| 4369	| 12606 |
|ENSMUSG00000000078	| 0	| 0	| 0	| 0	| 0	| 0	| 0	| 0 |
|ENSMUSG00000000085	| 44	| 8	| 64	| 59	| 18	| 32	| 37	| 7 |

- Design matrix
  - Text file, tab separated
  - First column: "sample" . Containes sample names *that need to be exactly the same as column names 2:N of the matrix files*
    Note: if this is not the case, the program will throw an error and stop.
  - The other columns contain information about each sample
  
 Example:
 | sample | treatment | site | sex |
 |--------|-----------|------|-----|
 |sample1 | drug      |liver |F    |
 |sample2 | drug      |liver |M    |
 |sample3 | drug      |kidney|F    |
 |sample4 | drug      |kidney|M    |
 |sample5 | control   |liver |F    |
 |sample6 | control   |liver |M    |
 |sample7 | control   |kidney|F    |
 |sample8 | control   |kidney|M    |

- JSON file
  - Contains the variables and file paths needed to run the pipeline
  - Template found in the /data directory of this repository
  - For information on how to modify the JSON to run your analysis, go to *Operating instructions*


## 1. Requirements
The pipeline is written in R scripts called from a bash script.
R version 3.6.2 (2019-12-12)

### Attached packages
- latticeExtra_0.6-29
- lattice_0.20-40   
- readr_1.3.1    
- factoextra_1.0.6  
- dplyr_0.8.5      
- Gviz_1.30.3    
- pcaMethods_1.78.0  
- ggplot2_3.3.0 
- SparkR_2.4.5               
- stringr_1.4.0  
- genefilter_1.68.0  
- DESeq2_1.26.0    
- SummarizedExperiment_1.16.1
- DelayedArray_0.12.2   
- BiocParallel_1.20.1        
- matrixStats_0.56.0    
- Biobase_2.46.0           
- GenomicRanges_1.38.0     
- GenomeInfoDb_1.22.0   
- IRanges_2.20.2           
- S4Vectors_0.24.3  
- BiocGenerics_0.32.0  
- forestmangr_0.9.1       
- jsonlite_1.6.1   



#### Libraries


A repository containing the steps for an automated PCA pipeline on a gene estimated counts matrix. Runs on R scripts through bash. Takes JSON file as input.
The pipeline runs on R script
The pipeline was designed for estimated counts and takes as inputs an estimated counts matrix and the corresponding design matrix.

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
