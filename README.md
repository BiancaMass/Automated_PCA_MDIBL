# Automated_PCA_MDIBL
This repository contains a pipeline that identifies unexpected variables in an expression data matrix. It performs normalization on the count matrix, PC Analysis, and regression on the PCs vs experimental design. Once unexpected variables are identified, their PC coordinates are captured into a modified design file, to be used for downstream analysis as surrogates of e unexpected variable(s).


1. Input files
2. System requirements
3. Operating instructions
4. Outputs
5. Provided files list
6. Copyright and licensing 
7. Contact information
8. Known bugs
9. Credits and acknowledgements


## 1. Input files
- Estimated counts matrix.
  - Text file, tab ("\t") separated.
  - Gene IDs are in rows, samples are in columns
  - First column contains the row names (gene_ids)
  - First row contains the column headers (gene_id and then sample names)

Example:

| gene_id	| sample1	| sample2	| sample3	| sample4	| sample5	| sample6	| sample7	| sample8 |
|---------|---------|---------|---------|---------|---------|---------|---------|---------|
|ENSMUSG00000000001	| 2 | 3 |	4	| 7	| 3	| 5	| 1	| 3 |
|ENSMUSG00000000037	| 10190 | 4432 | 2244 |	2797 | 2540	| 15565	| 4369	| 12606 |
|ENSMUSG00000000078	| 0	| 0	| 0	| 0	| 0	| 0	| 0	| 0 |
|ENSMUSG00000000085	| 44	| 8	| 64	| 59	| 18	| 32	| 37	| 7 |

- Design matrix
  - Text file, tab ("\t") separated
  - The first row contains column headers
  - First column contains the sample names *that need to be exactly the same as column names 2:N of the count matrix*
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
  - It should be structured as follows:
  
``` 
{
  "input_files": {
    "infile1":"/path/to/design/file.txt",
    "infile2":"/path/to/count_matrix/file.txt",
    "experiment_name": "name_of_my_experiment"
  },
  
  "folders":{
    "parent_folder":"path/to/parent/folder"
  },
  
  "input_variables":{
    "min_gene_tot_raw_count": 1,
    "min_count_mean":0,
    "mean_precentage_threshold":0.25,
    "sd_precentage_threshold":0.25,
    "R_squared_threshold":0.95,
    "max_number_PC_regression":9
  },
  
    "design_formula":{
            "design1":"treatment",
            "design2":"site"     
    }  
}
```

Refer to *Operating Instructions* to know which variables to change in order to run the pipeline.


## 2. Requirements
The pipeline is written in R scripts called from a bash script.
R version 3.6.2 (2019-12-12)

#### Attached packages
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
- grDevices_3.6.2

## 3. Operating instructions

To run the pipeline, do the following:

1. Create a folder on your machine (parent folder), containing the following subfolders:
- scripts
- data

2. Save your data (estimated count matrices and design files) in the data folder, together with the json input file (found in the /data folder of this GitHub repository).

3. Save the scripts from in the scripts folder (scripts are in the /scripts folder of this GitHub repository).

4. Open the bash script "bash_automated_pca.sh"

5. Change the following variables in the bash script:
  - PARENT_DIR=~/path/2/your/parent/folder/
  - JSON_FILE_NAME=name_of_your_json.json
  
 5. Change the variables in the json file to fit your file paths and desired parameters as follows:
  -  "infile1": path to your design file. e.g. "/home/bmass/projects/pipeline/data/experiment_12_design.txt"
  -  "infile2": path to your design file. e.g. "/home/bmass/projects/pipeline/data/experiment_12_estcounts.txt"
  -  "experiment_name": name of your experiment. This is used to name output files. e.g. "experiment_12"
  -  "parent_folder": path to your parent folder e.g. "/home/bmass/projects/pipeline/"
  -  "design1": the name of the column of the design file which will be your first element of the design formula e.g. "treatment"
  -  "design2": the name of the column of the design file which will be your second element of the design formula e.g. "sex"

Note: the formula is used in the function DESeq2::DESeqDataSetFromMatrix(). Refer to the [documentation](https://www.rdocumentation.org/packages/DESeq2/versions/1.12.3/topics/DESeqDataSet-class).

# *** Insert more details on the design formula ***
  
 6. In the terminal, cd to the parent_folder/scripts and run the following command:
 bash bash_automated_pca.sh

## 4. Outputs

The outputs of the pipeline can be found in the following subdirectories:
  - /results
  - /figures
  - /report

# *** Instert output list ***

## 5. Provided files list
## 6. Copyright and licensing 
## 7. Contact information
## 8. Known bugs
## 9. Credits and acknowledgements

