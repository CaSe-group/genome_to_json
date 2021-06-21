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

parser.add_argument('-a', '--abricate', help = "Input Abricate-file", required = True)
parser.add_argument('-i', '--hashid', help = "Input hashID", required = True)
parser.add_argument('-o', '--output', help = "Output-directory", default = os.getcwd())
parser.add_argument('-p', '--proka', help = "Input Proka-file", required = True)
parser.add_argument('-s', '--sourmash', help = "Input Sourmash-file", required = True)

#parsing:
arg = parser.parse_args()

#define arguments as variables:
ABRICATE_INPUT = arg.abricate
HASHID_INPUT = arg.hashid
OUTPUT_DIR = arg.output
PROKA_INPUT = arg.proka
SOURMASH_INPUT = arg.sourmash


################################################################################
## Set up results-directory & change working-directory if necessary

#check if output-directory exists & create a Results-directory in it:
OUTPUT_PATH = str(OUTPUT_DIR) + '/'
os.makedirs(OUTPUT_PATH, exist_ok = True)

#check if output-flag was used:
if OUTPUT_PATH != os.getcwd():
        
    #change working directory to the path
    os.chdir(OUTPUT_PATH)


################################################################################
## Dataframe-creation

DF_ABRICATE = pd.read_csv(ABRICATE_INPUT, sep = '\t')
DF_PROKA = pd.read_csv(PROKA_INPUT)
DF_SOURMASH = pd.read_csv(SOURMASH_INPUT)


################################################################################
## Parsing-functions

OUTPUT_FILE_NAME = str(HASHID_INPUT) + "_mongodb_report.json"

def json_file_opening(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "w")
	RESULT_FILE.write("{\n")
	RESULT_FILE.close()
	return RESULT_FILE

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
	RES_GENE_LIST = DF_ABRICATE['GENE'].values
	if RES_GENE_LIST[0] == 'nan':
		RES_GENE_LIST[0] = 'no_resistance_genes'
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Resistance_Genes\": {\n")
	[RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\",\n") if RES_GENE != RES_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\"\n") for RES_GENE in RES_GENE_LIST]
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def analysing_date_parsing(OUTPUT_FILE_NAME):
	DATE = os.popen('date -I | tr -d "-" |tr -d "\n"')
	ANALYSING_DATE = DATE.read()
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def json_file_closing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("}")
	RESULT_FILE.close()
	return RESULT_FILE


################################################################################
## Function calls

json_file_opening(OUTPUT_FILE_NAME)
hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)
status_parsing(OUTPUT_FILE_NAME)
res_gene_parsing(OUTPUT_FILE_NAME, DF_ABRICATE)
analysing_date_parsing(OUTPUT_FILE_NAME)
json_file_closing(OUTPUT_FILE_NAME)