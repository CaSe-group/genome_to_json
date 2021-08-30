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
parser.add_argument('-n', '--new_entry', help = "Activates parsing of hash-ID as sample-ID", default = 'false' )
parser.add_argument('-o', '--output', help = "Output-directory", default = os.getcwd())
parser.add_argument('-p', '--prokka', help = "Input Prokka-file", default = 'false')
parser.add_argument('-s', '--sourmash', help = "Input Sourmash-file", default = 'false')

#parsing:
arg = parser.parse_args()

#set arguments as variables:
ABRICATE_INPUT = arg.abricate
HASHID_INPUT = arg.hashid
NEW_ENTRY = arg.new_entry
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

def sample_id_parsing(OUTPUT_FILE_NAME, HASHID_INPUT):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"Sample_ID\": \"{HASHID_INPUT}\",\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_parsing(OUTPUT_FILE_NAME, DF_ABRICATE, ABRICATE_DB_VERSION, ANALYZING_DATE):
	RES_GENE_LIST = DF_ABRICATE['GENE'].values							#get list of all entries of 'GENE'-column in abricate-dataframe
	if len(RES_GENE_LIST) == 0:											#check if length of the list = 0
		RES_GENE_LIST = ['no_resistance_genes']							#if true set variable to single element list
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Abricate\": {\n")
	RESULT_FILE.write(f"        \"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"        \"Abricate_Db_Version\": \"{ABRICATE_DB_VERSION}\",\n")
	[RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\",\n") if RES_GENE != RES_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\"\n") for RES_GENE in RES_GENE_LIST]
	#list comprehension over all RES_GENE´s in RES_GENE_LIST -> writes '"RES_GENE": "true",' to RESULT_FILE if not last list-element; else writes '"RES_GENE": "true"' (without comma)
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def prokka_parsing(OUTPUT_FILE_NAME, DF_PROKKA, PROKKA_VERSION, ANALYSING_DATE):
	PROKKA_GENE_LIST = DF_PROKKA['gene'].values
	if len(PROKKA_GENE_LIST) == 0:
			PROKKA_GENE_LIST = ['no_genes_detected']
	PROKKA_GENE_LIST = PROKKA_GENE_LIST[~pd.isnull(PROKKA_GENE_LIST)]	#select all elements from PROKKA_GENE_LIST that are not null
	PROKKA_GENE_LIST = np.unique(PROKKA_GENE_LIST)						#remove duplicates from PROKKA_GENE_LIST
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Prokka\": {\n")
	RESULT_FILE.write(f"        \"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"        \"Prokka_Version\": \"{PROKKA_VERSION}\",\n")	
	[RESULT_FILE.write(f"        \"{GENE}\": \"true\",\n") if GENE != PROKKA_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{GENE}\": \"true\"\n") for GENE in PROKKA_GENE_LIST]
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def sourmash_parsing(OUTPUT_FILE_NAME, DF_SOURMASH, ANALYSING_DATE):
	STATUS = DF_SOURMASH['status'].values[0]
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Sourmash\": {\n")
	RESULT_FILE.write(f"        \"Analysing_Date\": {ANALYSING_DATE},\n")

	if STATUS == 'found':
		TAX_SUPERKINGDOM = DF_SOURMASH['superkingdom'].values[0]
		TAX_PHYLUM = DF_SOURMASH['phylum'].values[0]
		TAX_CLASS = DF_SOURMASH['class'].values[0]
		TAX_ORDER = DF_SOURMASH['order'].values[0]
		TAX_FAMILY = DF_SOURMASH['family'].values[0]
		TAX_GENUS = DF_SOURMASH['genus'].values[0]
		TAX_SPECIES = DF_SOURMASH['species'].values[0]
		TAX_STRAIN = DF_SOURMASH['strain'].values[0]

		RESULT_FILE.write(f"        \"superkingdom\": \"{TAX_SUPERKINGDOM}\",\n")
		RESULT_FILE.write(f"        \"phylum\": \"{TAX_PHYLUM}\",\n")
		RESULT_FILE.write(f"        \"class\": \"{TAX_CLASS}\",\n")
		RESULT_FILE.write(f"        \"order\": \"{TAX_ORDER}\",\n")
		RESULT_FILE.write(f"        \"family\": \"{TAX_FAMILY}\",\n")
		RESULT_FILE.write(f"        \"genus\": \"{TAX_GENUS}\",\n")
		RESULT_FILE.write(f"        \"species\": \"{TAX_SPECIES}\",\n")
		RESULT_FILE.write(f"        \"strain\": \"{TAX_STRAIN}\"\n")

	elif STATUS == 'disagree':
		RESULT_FILE.write(f"        \"contamination\": \"true\"")
	
	else:
		RESULT_FILE.write("			\"classification failed\": \"true\" ")
	
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def status_parsing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Status\": \"analysed\"\n")	#no comma after this line, because last line of the file
	RESULT_FILE.close()
	return RESULT_FILE

def json_file_closing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("}")
	RESULT_FILE.close()
	return RESULT_FILE


################################################################################
## Function calls

DATE = os.popen('date -I | tr -d "-" |tr -d "\n"')					#create bash-output of parsed date
ANALYSING_DATE = DATE.read()										#interpret bash-output in python

json_file_opening(OUTPUT_FILE_NAME)										#trigger function 'json_file_opening' with according input

if NEW_ENTRY != 'false':
	sample_id_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)
else:
	hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)

if ABRICATE_INPUT != 'false':
	ABRICATE_FILE = ABRICATE_INPUT.split(',')[0]						#split abricate-input by ',' taking the first resulting element
	ABRICATE_DB_VERSION = ABRICATE_INPUT.split(',')[1]					#split abricate-input by ',' taking the second resulting element
	DF_ABRICATE = pd.read_csv(ABRICATE_FILE, sep = '\t')				#create pandas-dataframe from abricate-file with tab-stop as separator
	
	abricate_parsing(OUTPUT_FILE_NAME, DF_ABRICATE, ABRICATE_DB_VERSION, ANALYSING_DATE)

if PROKKA_INPUT != 'false':
	PROKKA_FILE = PROKKA_INPUT.split(',')[0]
	PROKKA_VERSION = PROKKA_INPUT.split(',')[1]
	DF_PROKKA = pd.read_csv(PROKKA_FILE, sep = '\t')
	
	prokka_parsing(OUTPUT_FILE_NAME, DF_PROKKA, PROKKA_VERSION, ANALYSING_DATE)

if SOURMASH_INPUT != 'false':
	DF_SOURMASH = pd.read_csv(SOURMASH_INPUT)
	sourmash_parsing(OUTPUT_FILE_NAME, DF_SOURMASH, ANALYSING_DATE)

status_parsing(OUTPUT_FILE_NAME)
json_file_closing(OUTPUT_FILE_NAME)
