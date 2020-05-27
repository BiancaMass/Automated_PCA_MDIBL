# Automated_PCA_MDIBL
This repository contains a pipeline that identifies unexpected variables in an expression data matrix. It performs normalization on the count matrix, PC Analysis, and regression on the PCs vs. experimental design. Once meaningful principal components are identified, their coordinates are captured into a modified design file, to perform further regression and, in case no correlation is found between PC and design equation variables, to be used for downstream analysis as surrogates of unexpected variable(s).


1. Requirements
2. Input files format
3. Operating instructions
4. Outputs
5. Provided files list
6. Copyright and licensing 
7. Contact information
8. Known bugs
9. Credits and acknowledgments

## 1. Requirements
The pipeline is written in R scripts called from a bash script.
R version 3.6.2 (2019-12-12)

#### Required packages
1.  DESeq2
2.  dplyr
3.  factoextra
4.  forestmangr
5.  genefilter
6.  ggplot2
7.  jsonlite
8.  knitr
9.  readr
10. rmarkdown
11. stringr


## 2. Input files format
Below are the format requirements for the input files.

- Estimated counts matrix.
  - Text file, tab ("\t") separated.
  - Gene IDs are in rows, samples are in columns
  - The first column contains the row names (gene_ids)
  - The first row contains the column headers ("gene_id" and then sample names)

Example:

| gene_id	        | sample1 | sample2	| sample3 | sample4	| sample5 | sample6	| sample7 | sample8 |
|-------------------|---------|---------|---------|---------|---------|---------|---------|---------|
|ENSMUSG00000000001	| 2       | 3       |	4	  | 7	    | 3	      | 5	    | 1	      | 3       |
|ENSMUSG00000000037	| 10190   | 4432    | 2244    |	2797    | 2540 	  | 15565	| 4369	  | 12606   |
|ENSMUSG00000000078	| 0	      | 0	    | 0	      | 0	    | 0	      | 0	    | 0	      | 0       |
|ENSMUSG00000000085	| 44	  | 8	    | 64	  | 59	    | 18	  | 32	    | 37      | 7       |

- Design matrix
  - Text file, tab ("\t") separated
  - The first row contains column headers
  - The first column contains the sample names that need to be exactly the same as column names 2:N of the count matrix
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
    "infile1":"/full/path/2/design_file.txt",
    "infile2":"/full/path/2/counts_file.txt",
    "experiment_name": "experiment_name"
  },
  
  "folders":{
    "parent_folder":"/full/path/to/parent_folder"
  },
  
  "input_variables":{
    "min_gene_tot_raw_count": 1,
    "min_count_mean":0,
    "mean_precentage_threshold":0.25,
    "sd_precentage_threshold":0.25,
    "R_squared_threshold":0.95,
    "max_number_PC_regression":9
    
  },
    
    "design_variables":{
            "design1":"variable1",
            "design2":"variable2"
            
    },
    
     "design_formula":{
            "design":"design ~ formula"
            
    }
    
}
```

Numeric values displayed above correspond to default values. Follows a description of what each numeric parameter is used for:

  - "min_gene_tot_raw_count": 1,
  - "min_count_mean":0,
  - "mean_precentage_threshold":0.25,
  - "sd_precentage_threshold":0.25,
  - "R_squared_threshold":0.95,
  - "max_number_PC_regression":9

## 3. Operating instructions

To run the pipeline, do the following:

1. Create a folder on your machine (parent folder), containing the following subfolders:
- scripts
- data

2. Save your data (estimated count matrices and design files) in the data folder, together with the JSON input file (found in the /data folder of this GitHub repository). Note: there are specific formatting requirements for the design and count matrices files, as specified in the *Input files* section.

3. Save the scripts from in the scripts folder (scripts are in the /scripts folder of this GitHub repository).
  
4. Open your JSON input file (stored in parent_folder/data). Change the following variables to fit your file paths and desired parameters:
  -  "infile1": full path to your design file. e.g. "/home/user/projects/pipeline/data/exp_design.txt"
  -  "infile2": full path to your counts file. e.g. "/home/user/projects/pipeline/data/exp_estcounts.txt"
  -  "experiment_name": name of your experiment. This is used to name output files. e.g. "exp"
  -  "parent_folder": full path to your parent folder e.g. "/home/user/projects/pipeline"
  -  "design_variables"$"design1": Column header from the design file e.g. "site". It should be identical to the header in the design file (no typos, careful with white spaces). This parameter is used to calculate the correlation between each meaningful PC and the parameter itself. The program calculates linear correlation with no interaction terms. It is also used to generate a correlation plot and to label points in a PC plot. 
  -  "design_variables"$"design2": Column header from the design file e.g. "treatment". It should be identical to the header in the design file (no typos, careful with white spaces). This parameter is used to calculate the correlation between each meaningful PC and the parameter itself. The program calculates linear correlation with no interaction terms. It is also used to generate a correlation plot and to label points in a PC plot. It can be empty.
  -  "design_formula"$"design": The design formula used to construct a DESeq2 data set e.g. "~ group + treatment". This will be fed as the 'design' argument in DESeqDataSetFromMatrix(). Refer to the package [documentation](https://www.rdocumentation.org/packages/DESeq2/versions/1.12.3/topics/DESeqDataSet-class) for more information on the design formula. Note: if there is no design formula, "~1" can be used for no design.

The other variables in the JSON file are numeric parameters that can be optionally changed to fit the analysis. Under the *Input files* section there is a description of what each numeric parameter is used for.
  
 5. In the terminal, cd to the parent_folder/scripts and call the bash script "bash_automated_pca.sh" with two arguments:
 	- the full path to your parent folder
	- the name of the JSON input file (stored in parent_folder/data)
 
 The command should look as follow:
 
 bash bash_automated_pca.sh ~/path/2/your/parent/folder/ name\_of\_your_json.json

 6. The pipeline will run and save its outputs in sub-folders in the parent directory. See *Outputs* for more information.


## 4. Outputs

The outputs of the pipeline can be found in the following subdirectories:
  - /results 
  - /figures
  - /report

Follows a description of each output file by storing directory. All .txt files are tab-separated.

  - /results:
	1.  ExperimentName\_design_meaningful.txt -> a copy of the design matrix with coordinates of the samples on each meaningful PC appended as new columns.
	
	
	2.  ExperimentName_design.txt -> A copy of the input design file.
	
	3.  ExperimentName\_genecounts_means.txt -> 
	
	4.  ExperimentName\_genecounts_sd.txt -> 
	
	5.  ExperimentName\_json_copy.json -> A copy of the input JSON file, with appended file paths to output tables, figures and objects.
	
	6.  ExperimentName\_meaningful\_pc_loading_scores.txt -> Loading scores only of the PC that were found to be meaningful through linear regression (see step 6).
	
	7.  ExperimentName\_pca_eigenvalues.txt -> Eigenvalues for all PC, including raw values, explained variance in percent, and cumulative explained variance in percent. 
	
	8.  ExperimentName\_pca\_loading_scores.txt -> Loading scores of all PCs.
	
	9.  ExperimentName\_pca_object.rds -> PCA R-object (RDS). Output of prcomp().
	
	10. ExperimentName\_regression\_pc_eigen.txt -> Results of the regression of Eigenvalues vs. component number as performed in step 6.
	
	11. ExperimentName\_rld_normalized.txt or. ExperimentName\_vst_normalized.txt -> Respectively, result of the rlog() or vst() normalization performed in step 2. Choice of function depends on matrix size (cut-off: ncol count matrix <= 30 for rlog(), else vst()).
	
	12. ExperimentName\_xxxxxx_correlation.txt -> Output of the correlation test between each meaningful PC and the variable indicated in JSON -> design_variables -> design1. xxxxxx stands for that variable.
	
	13. ExperimentName\_yyyyyy_correlation.txt -> Output of the correlation test between each meaningful PC and the variable indicated in JSON -> design_variables -> design2. yyyyyy stands for that variable. Optional, only if yyyyyy exists.
	
	14. ExperimentName\_Z_mean_stdev.txt -> The counts table, after Z-transformation, with mean and sd after rlog() or vst() normalization (used for the Z-transformation itself).
	
	15. ExperimentName\_Z_normalized.txt -> The counts table, after Z-transformation (step 3).
	
	16. ExperimentName\_Z_threshold.txt -> The counts table after Z-transformation, and filtered for sufficient variation and expression level (step 4). Thresholds are indicated in JSON -> input_variables -> sd_precentage_threshold and JSON -> input_variables -> mean_precentage_threshold
	

  - /figures:
	
	1.  ExperimentName\_cor_plot_1.png : Correlation plot between design_variables$design1 from the JSON and the coordinate of each sample on each meaningful PC.

	2.  ExperimentName\_cor_plot_2.png : Optional plot, only if design\_variables$design2 exists. Correlation plot between design\_variables$design2 from the JSON and the coordinate of each sample on each meaningful PC.

	3.  ExperimentName\_log10scree_plot.png : Scree plot with Eigenvalues converted to log10. 

	4.  ExperimentNamemean\_histogram.png : Histogram of the raw standard deviations (of each gene across all samples). The dotted line represent filtering threshold as indicated in json\$input\_variables$mean\_precentage_threshold.

	5.  ExperimentNamePC1\_PC2.png : PC1 vs. PC2 coordinates with percentage of variance explained. Text is determined by json\$design\_variables\$design1, color by json\$design\_variables\$design2.

	6.  ExperimentNamePC2_PC3.png : PC2 vs. PC3 coordinates with percentage of variance explained. Text is determined by json\$design\_variables\$design1, color by json\$design\_variables\$design2.

	7.  ExperimentNameraw\_mean_sd.png : mean vs. sd for each gene across sample of the raw count matrix.

	8.  ExperimentName\_regression\_plot.png : Linear regression of the log10 Eigenvalues vs. PC number for 1->N, 2->N.... x->N where N is the total number of PCs and x is the max number of regressions as indicated in json\$input\_variables\$max_number_PC_regression.

	9.  ExperimentName\_rlog\_vsd\_mean_sd.png : mean vs. standard deviation for each gene across sample of the standardized count matrix (with DESeq2::rlog or DESeq2::vst).

	10. ExperimentNamescree_plot.png : Regular scree plot of the experiment.

	11. ExperimentNamesd\_histogram.png : Histogram of the raw standard deviations (of each gene across all samples). The dotted line represent filtering threshold as indicated in json\$input\_variables$mean\_precentage_threshold.

	12. ExperimentNameZ\_mean_sd.png : mean vs. standard deviation of each gene across all samples after Z-transormation (sd should be == 1, mean should be very close to 0). 

  - /report:
	1. ExperimentName_results.html : The automated report with a summary of each step, plots, and outputs.

## 5. Provided files list

The files provided and needed for the correct functioning of the pipeline are the following:

  - /scripts:
	1.  automated_report.R
	2.  bash\_automated_pca.sh
	3.  final_report.Rmd
	4.  step_00.R
	5.  step_01.R
	6.  step_02.R
	7.  step_03.R
	8.  step_04.R
	9.  step_05.R
	10.  step_06.R
	11. step_07.R

  - /data:
	1. pipeline\_input_file.json



## 6. Copyright and licensing 
## 7. Contact information
For any questions please contact Bianca M. Massacci at bianca.massacci@gmail.com

## 8. Known bugs
## 9. Credits and acknowledgements
I thank Joel Graber, Ph.D. Senior Staff Scientist and Director of Computational Biology and Bioinformatics Core at the MDI Biological Laboratory, and Daniel M. Gatti, Ph.D. Faculty of Computer Science at College of the Atlantic for helping me in the process of designing and completing this project.
