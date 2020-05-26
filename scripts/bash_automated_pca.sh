#!/bin/bash
# Calls for each step in the automated PCA pipeline

### Change these variables:

PARENT_DIR=/path/to/parent/folder/
JSON_FILE_NAME=pipeline_input_file.json


##########################################
######## Do not change below here ########
##########################################

echo "*** Create a report folder if it does not exist ***"
if [ ! -d ${PARENT_DIR}report ] 
then
    mkdir -p ${PARENT_DIR}report
fi 


echo "*** Create a results folder if it does not exist ***"
if [ ! -d ${PARENT_DIR}results ] 
then
    mkdir -p ${PARENT_DIR}results
fi 

echo "*** Create a figures folder if it does not exist ***"
if [ ! -d ${PARENT_DIR}figures ] 
then
    mkdir -p ${PARENT_DIR}figures
fi 


DATA_FOLDER=${PARENT_DIR}data/
REPORT_FOLDER=${PARENT_DIR}report/
SCRIPTS_FOLDER=${PARENT_DIR}scripts/
RESULTS_FOLDER=${PARENT_DIR}results/
FIGURES_FOLDER=${PARENT_DIR}figures/

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
Rscript ${SCRIPTS_FOLDER}step_01.R ${JSON_PATH}
echo Leaving step_01.R

echo "********************************************"
echo Entering step_02.R
Rscript ${SCRIPTS_FOLDER}step_02.R ${JSON_PATH}
echo Leaving step_02.R

echo "********************************************"
echo Entering step_03.R
Rscript ${SCRIPTS_FOLDER}step_03.R ${JSON_PATH}
echo Leaving step_03.R

echo "********************************************"
echo Entering step_04.R
Rscript ${SCRIPTS_FOLDER}step_04.R ${JSON_PATH}
echo Leaving step_04.R

echo "********************************************"
echo Entering step_05.R
Rscript ${SCRIPTS_FOLDER}step_05.R ${JSON_PATH}
echo Leaving step_05.R

echo "********************************************"
echo Entering step_06.R
Rscript ${SCRIPTS_FOLDER}step_06.R ${JSON_PATH}
echo Leaving step_06.R

echo "********************************************"
echo Entering step_07.R
Rscript ${SCRIPTS_FOLDER}step_07.R ${JSON_PATH}
echo Leaving step_07.R

echo "********************************************"
echo Entering automated_report.R
echo "*** This script calls an R markdown that will save an automated report file in the report folder ***"
Rscript ${SCRIPTS_FOLDER}automated_report.R ${JSON_PATH}
echo Leaving automated_report.R

