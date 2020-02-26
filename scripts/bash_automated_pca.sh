#!/bin/bash
# Calls for each step in the automated PCA pipeline

# Change these variables:

PARENT_DIR=~/Documents/senior_project/automated_pca/
JSON_FILE_NAME=pipeline_input_file.json

# Do not change:

DATA_FOLDER=${PARENT_DIR}data/
REPORT_FOLDER=${PARENT_DIR}report/
SCRIPTS_FOLDER=${PARENT_DIR}scripts/
RESULTS_FOLDER=${PARENT_DIR}results/

JSON_PATH=${DATA_FOLDER}$JSON_FILE_NAME


echo "********************************************"
echo File paths provided
echo data folder: ${DATA_FOLDER}
echo report folder: ${REPORT_FOLDER}
echo scripts folder: ${SCRIPTS_FOLDER}
echo results folder: ${RESULTS_FOLDER}
echo json file path: ${JSON_PATH}

echo "********************************************"
echo Entering step_01.R
Rscript step_01.R ${JSON_PATH}
echo Leaving step_01.R

echo "********************************************"
echo Entering step_02_01.R
Rscript step_02_01.R ${JSON_PATH}
echo Leaving step_02_01.R

echo "********************************************"
echo Entering step_03.R
Rscript step_03.R ${JSON_PATH}
echo Leaving step_03.R

