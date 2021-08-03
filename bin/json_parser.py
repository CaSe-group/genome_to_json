#!/usr/bin/env python3

################################################################################
## Module-import

import argparse
import pandas as pd
import numpy as np
import os
import sys


################################################################################
## Initialization

parser = argparse.ArgumentParser(description = 'Create json-file for upload to MongoDB from different result-files.')

#define arguments
parser.add_argument('-a', '--abricate', help = "Input Abricate-file", default = 'False')
parser.add_argument('-i', '--hashid', help = "Input hashID", required = True)
parser.add_argument('-o', '--output', help = "Output-directory", default = os.getcwd())
parser.add_argument('-p', '--prokka', help = "Input Prokka-file", default = 'False')
parser.add_argument('-s', '--sourmash', help = "Input Sourmash-file", default = 'False')

#parsing:
arg = parser.parse_args()

#set arguments as variables:
ABRICATE_INPUT = arg.abricate
HASHID_INPUT = arg.hashid
OUTPUT_DIR = arg.output
PROKKA_INPUT = arg.prokka
SOURMASH_INPUT = arg.sourmash


################################################################################
## Set up results-directory & change working-directory if necessary

#check if output-directory exists & create a Results-directory in it:
OUTPUT_PATH = str(OUTPUT_DIR) + '/'
os.makedirs(OUTPUT_PATH, exist_ok = True)								#create dir if not existant in OUTPUT_PATH

#check if output-flag was used:
if OUTPUT_PATH != os.getcwd():											#if OUTPUT_PATH != $PWD
    os.chdir(OUTPUT_PATH)												#change working-dir to OUTPUT_PATH


################################################################################
## Parsing-functions

OUTPUT_FILE_NAME = str(HASHID_INPUT) + "_mongodb_report.json"

def json_file_opening(OUTPUT_FILE_NAME):								#define function taking OUTPUT_FILE_NAME as input
	RESULT_FILE = open(OUTPUT_FILE_NAME, "w")							#open file with write access under variable RESULT_FILE
	RESULT_FILE.write("{\n")											#write to RESULT_FILE
	RESULT_FILE.close()													#close file
	return RESULT_FILE													#end function by returning RESULT_FILE to global environment

def hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"_id\": {\n")
	RESULT_FILE.write(f"        \"$oid\": \"{HASHID_INPUT}\"\n")
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def status_parsing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Status\": \"analysed\",\n")
	RESULT_FILE.close()
	return RESULT_FILE

def res_gene_parsing(OUTPUT_FILE_NAME, DF_ABRICATE):
	RES_GENE_LIST = DF_ABRICATE['GENE'].values							#get list of all entries of 'GENE'-column in abricate-dataframe
	if len(RES_GENE_LIST) == 0:											#check if length of the list = 0
		RES_GENE_LIST = ['no_resistance_genes']							#if true set variable to single element list
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Resistance_Genes\": {\n")
	[RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\",\n") if RES_GENE != RES_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\"\n") for RES_GENE in RES_GENE_LIST]
	#list comprehension over all RES_GENE´s in RES_GENE_LIST -> writes '"RES_GENE": "true",' to RESULT_FILE if not last list-element; else writes '"RES_GENE": "true"' (without comma)
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_db_version_parsing(OUTPUT_FILE_NAME, ABRICATE_DB_VERSION):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"Abricate_Db_Version\": \"{ABRICATE_DB_VERSION}\",\n")

def prokka_parsing(OUTPUT_FILE_NAME, DF_PROKKA):
	PROKKA_GENE_LIST = DF_PROKKA['gene'].values
	if len(PROKKA_GENE_LIST) == 0:
			PROKKA_GENE_LIST = ['no_genes_detected']
	PROKKA_GENE_LIST = PROKKA_GENE_LIST[~pd.isnull(PROKKA_GENE_LIST)]	#select all elements from PROKKA_GENE_LIST that are not null
	PROKKA_GENE_LIST = np.unique(PROKKA_GENE_LIST)						#remove duplicates from PROKKA_GENE_LIST
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Genes\": {\n")
	[RESULT_FILE.write(f"        \"{GENE}\": \"true\",\n") if GENE != PROKKA_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{GENE}\": \"true\"\n") for GENE in PROKKA_GENE_LIST]
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def analysing_date_parsing(OUTPUT_FILE_NAME):
	DATE = os.popen('date -I | tr -d "-" |tr -d "\n"')					#create bash-output of parsed date
	ANALYSING_DATE = DATE.read()										#interpret bash-output in python
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"Analysing_Date\": {ANALYSING_DATE}\n") 	#no comma after this line, because last line of the file
	RESULT_FILE.close()
	return RESULT_FILE

def json_file_closing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("}")
	RESULT_FILE.close()
	return RESULT_FILE


################################################################################
## Function calls

json_file_opening(OUTPUT_FILE_NAME)										#trigger function 'json_file_opening' with according input
hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)
status_parsing(OUTPUT_FILE_NAME)

if ABRICATE_INPUT != 'False':
	ABRICATE_FILE = arg.abricate.split(',')[0]							#split abricate-input by ',' taking the first resulting element
	ABRICATE_DB_VERSION = arg.abricate.split(',')[1]					#split abricate-input by ',' taking the second resulting element
	DF_ABRICATE = pd.read_csv(ABRICATE_FILE, sep = '\t')				#create pandas-dataframe from abricate-file with tab-stop as separator
	
	res_gene_parsing(OUTPUT_FILE_NAME, DF_ABRICATE)
	abricate_db_version_parsing(OUTPUT_FILE_NAME, ABRICATE_DB_VERSION)

if PROKKA_INPUT != 'False':
	DF_PROKKA = pd.read_csv(PROKKA_INPUT, sep = '\t')
	prokka_parsing(OUTPUT_FILE_NAME, DF_PROKKA)

if SOURMASH_INPUT != 'False':
	DF_SOURMASH = pd.read_csv(SOURMASH_INPUT)
	#sourmash_parsing()

analysing_date_parsing(OUTPUT_FILE_NAME)
json_file_closing(OUTPUT_FILE_NAME)
