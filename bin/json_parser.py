#!/usr/bin/env python3

################################################################################
## Module-import

from glob import glob

import argparse
import pandas as pd
import numpy as np
import os
import sys


################################################################################
## Initialization

parser = argparse.ArgumentParser(description = 'Create json-file for upload to MongoDB from different result-files.')

#define arguments
parser.add_argument('-a', '--abricate', help = "Input Abricate-files", default = 'false')
parser.add_argument('-b', '--bakta', help = "Input Bakta-files", default = 'false')
parser.add_argument('-i', '--hashid', help = "Input hashID", required = True)
parser.add_argument('-j', '--deep_json', help = "Generate deeper-leveled json-output with ABRicate & Sourmash", default = 'false')
parser.add_argument('-n', '--new_entry', help = "Activates parsing of hash-ID as sample-ID", default = 'false' )
parser.add_argument('-o', '--output', help = "Output-directory", default = os.getcwd())
parser.add_argument('-p', '--prokka', help = "Input Prokka-files", default = 'false')
parser.add_argument('-s', '--sourmash', help = "Input Sourmash-files", default = 'false')

#parsing:
arg = parser.parse_args()

#set arguments as variables:
ABRICATE_INPUT = arg.abricate
BAKTA_INPUT = arg.bakta
DEEP_JSON = arg.deep_json
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

def json_file_opening_deep(OUTPUT_FILE_NAME):								#define function taking OUTPUT_FILE_NAME as input
	RESULT_FILE = open(OUTPUT_FILE_NAME, "w")							#open file with write access under variable RESULT_FILE
	RESULT_FILE.write("[{\n")											#write to RESULT_FILE
	RESULT_FILE.close()													#close file
	return RESULT_FILE													#end function by returning RESULT_FILE to global environment

def hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"_id\": {\n")
	RESULT_FILE.write(f"\t\t\"$oid\": \"{HASHID_INPUT}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def sample_id_parsing(OUTPUT_FILE_NAME, HASHID_INPUT):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"\t\"Sample_ID\": \"{HASHID_INPUT}\",\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_info_parsing(OUTPUT_FILE_NAME, ANALYSING_DATE):
	ABRICATE_INFO_FILE_ALL_LINES = open(f"{ABRICATE_INFO_FILE}", "r").readlines()
	ABRICATE_VERSION = ' '.join(ABRICATE_INFO_FILE_ALL_LINES[0].split(':')[1:]).strip()
	ABRICATE_DB_VERSION = ' '.join(ABRICATE_INFO_FILE_ALL_LINES[1].split(':')[1:]).strip()
	ABRICATE_COMMAND = ' '.join(ABRICATE_INFO_FILE_ALL_LINES[2].split(':')[1:]).strip()
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Abricate_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Abricate_Version\": \"{ABRICATE_VERSION}\",\n")
	RESULT_FILE.write(f"\t\t\"Abricate_Db_Version\": \"{ABRICATE_DB_VERSION}\",\n")
	RESULT_FILE.write(f"\t\t\"Abricate_Command\": \"{ABRICATE_COMMAND}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_result_parsing(OUTPUT_FILE_NAME, DF_ABRICATE):
	RES_GENE_LIST = DF_ABRICATE['GENE'].values							#get list of all entries of 'GENE'-column in abricate-dataframe
	if len(RES_GENE_LIST) == 0:											#check if length of the list = 0
		RES_GENE_LIST = ['no_resistance_genes']							#if true set variable to single element list
	RES_GENE_LIST = list(dict.fromkeys(RES_GENE_LIST))
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Abricate_Result\": {\n")
	[RESULT_FILE.write(f"\t\t\"{RES_GENE}\": \"true\",\n") if RES_GENE != RES_GENE_LIST[-1] else RESULT_FILE.write(f"\t\t\"{RES_GENE}\": \"true\"\n") for RES_GENE in RES_GENE_LIST]
	#list comprehension over all RES_GENE´s in RES_GENE_LIST -> writes '"RES_GENE": "true",' to RESULT_FILE if not last list-element; else writes '"RES_GENE": "true"' (without comma)
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_result_parsing_deep(OUTPUT_FILE_NAME, DF_ABRICATE):
	RES_GENE_LIST = DF_ABRICATE['GENE'].values							#get list of all entries of 'GENE'-column in abricate-dataframe										#check if length of the list = 0	
	SEQUENCE_LIST = DF_ABRICATE['SEQUENCE'].values
	RESISTANCE_LIST = DF_ABRICATE['RESISTANCE'].values
	COVERAGE_LIST = DF_ABRICATE['%COVERAGE'].values
	IDENTITY_LIST = DF_ABRICATE['%IDENTITY'].values
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Abricate_Result\": {\n")
	if len(RES_GENE_LIST) == 0:
		RES_GENE_LIST = ['no_resistance_genes']							#if true set variable to single element list
		[RESULT_FILE.write(f"\t\t\"{RES_GENE_LIST[INDEX]}\": \"true\"") for INDEX in range(len(RES_GENE_LIST))]
	else:
		[RESULT_FILE.write(f"\t\t\"{RES_GENE_LIST[INDEX]}\": {{\n\t\t\t\"Sequence\": \"{SEQUENCE_LIST[INDEX]}\",\n\t\t\t\"Resistenz\": \"{RESISTANCE_LIST[INDEX]}\",\n\t\t\t\"Coverage\": \"{COVERAGE_LIST[INDEX]}\",\n\t\t\t\"Identity\": \"{IDENTITY_LIST[INDEX]}\"}},\n") if RES_GENE_LIST[INDEX] != RES_GENE_LIST[-1] else RESULT_FILE.write(f"\t\t\"{RES_GENE_LIST[INDEX]}\": {{\n\t\t\t\"Sequence\": \"{SEQUENCE_LIST[INDEX]}\",\n\t\t\t\"Resistenz\": \"{RESISTANCE_LIST[INDEX]}\",\n\t\t\t\"Coverage\": \"{COVERAGE_LIST[INDEX]}\",\n\t\t\t\"Identity\": \"{IDENTITY_LIST[INDEX]}\"}}\n") for INDEX in range(len(RES_GENE_LIST))]
	#list comprehension over all RES_GENE´s in RES_GENE_LIST -> writes for each entry nested tuple with Sequence, Resistance, Coverage & identity separated by comma (if not last list-element)
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def bakta_info_parsing(OUTPUT_FILE_NAME, BAKTA_VERSION_FILE, ANALYSING_DATE):
	BAKTA_VERSION = open(f"{BAKTA_VERSION_FILE}", "r").read().replace("\n","")
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Bakta_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Bakta_Version\": \"{BAKTA_VERSION}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def bakta_result_parsing(OUTPUT_FILE_NAME, DF_BAKTA):
	BAKTA_GENE_LIST = DF_BAKTA['Gene'].values
	if len(BAKTA_GENE_LIST) == 0:
			BAKTA_GENE_LIST = ['no_genes_detected']
	BAKTA_GENE_LIST = BAKTA_GENE_LIST[~pd.isnull(BAKTA_GENE_LIST)].tolist()
	
	STRIPPED_GENE_LIST = list(dict.fromkeys(BAKTA_GENE_LIST))	#remove duplicates by converting list to a dict using the elements as keys (each key can only exist once) & back to list

	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Bakta_Result\": {\n")
	[RESULT_FILE.write(f"\t\t\"{GENE}\": \"true\",\n") if GENE != STRIPPED_GENE_LIST[-1] else RESULT_FILE.write(f"\t\t\"{GENE}\": \"true\"\n") for GENE in STRIPPED_GENE_LIST]
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def prokka_info_parsing(OUTPUT_FILE_NAME, PROKKA_VERSION_FILE, ANALYSING_DATE):
	PROKKA_VERSION = open(f"{PROKKA_VERSION_FILE}", "r").read().replace("\n","")
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Prokka_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Prokka_Version\": \"{PROKKA_VERSION}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def prokka_result_parsing(OUTPUT_FILE_NAME, DF_PROKKA):
	PROKKA_GENE_LIST = DF_PROKKA['gene'].values
	if len(PROKKA_GENE_LIST) == 0:
			PROKKA_GENE_LIST = ['no_genes_detected']
	PROKKA_GENE_LIST = PROKKA_GENE_LIST[~pd.isnull(PROKKA_GENE_LIST)]	#select all elements from PROKKA_GENE_LIST that are not null
	PROKKA_GENE_LIST = np.unique(PROKKA_GENE_LIST)						#remove duplicates from PROKKA_GENE_LIST
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Genes\": {\n")
	[RESULT_FILE.write(f"\t\t\"{GENE}\": \"true\",\n") if GENE != PROKKA_GENE_LIST[-1] else RESULT_FILE.write(f"\t\t\"{GENE}\": \"true\"\n") for GENE in PROKKA_GENE_LIST]
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def sourmash_info_parsing(OUTPUT_FILE_NAME, SOURMASH_VERSION_FILE, ANALYSING_DATE):
	SOURMASH_VERSION = open(f"{SOURMASH_VERSION_FILE}", "r").read().replace("\n","")
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Sourmash_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Sourmash_Version\": \"{SOURMASH_VERSION}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def sourmash_result_parsing(OUTPUT_FILE_NAME, DF_SOURMASH):
	STATUS = DF_SOURMASH['status'].values[0]
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Sourmash_Result\": {\n")
	RESULT_FILE.write(f"\t\t\"Status\": \"{STATUS}\",\n")

	if STATUS == 'found':
		TAX_SUPERKINGDOM = str(DF_SOURMASH['superkingdom'].values[0])[3:] if str(DF_SOURMASH['superkingdom'].values[0]) != "nan" else str(DF_SOURMASH['superkingdom'].values[0])
		TAX_PHYLUM = str(DF_SOURMASH['phylum'].values[0])[3:] if str(DF_SOURMASH['phylum'].values[0]) != "nan" else str(DF_SOURMASH['phylum'].values[0])
		TAX_CLASS = str(DF_SOURMASH['class'].values[0])[3:] if str(DF_SOURMASH['class'].values[0]) != "nan" else str(DF_SOURMASH['class'].values[0])
		TAX_ORDER = str(DF_SOURMASH['order'].values[0])[3:] if str(DF_SOURMASH['order'].values[0]) != "nan" else str(DF_SOURMASH['order'].values[0])
		TAX_FAMILY = str(DF_SOURMASH['family'].values[0])[3:] if str(DF_SOURMASH['family'].values[0]) != "nan" else str(DF_SOURMASH['family'].values[0])
		TAX_GENUS = str(DF_SOURMASH['genus'].values[0])[3:] if str(DF_SOURMASH['genus'].values[0]) != "nan" else str(DF_SOURMASH['genus'].values[0])
		TAX_SPECIES = str(DF_SOURMASH['species'].values[0])[3:] if str(DF_SOURMASH['species'].values[0]) != "nan" else str(DF_SOURMASH['species'].values[0])
		TAX_STRAIN = str(DF_SOURMASH['strain'].values[0])[3:] if str(DF_SOURMASH['strain'].values[0]) != "nan" else str(DF_SOURMASH['strain'].values[0])

		RESULT_FILE.write(f"\t\t\"superkingdom\": \"{TAX_SUPERKINGDOM}\",\n")
		RESULT_FILE.write(f"\t\t\"phylum\": \"{TAX_PHYLUM}\",\n")
		RESULT_FILE.write(f"\t\t\"class\": \"{TAX_CLASS}\",\n")
		RESULT_FILE.write(f"\t\t\"order\": \"{TAX_ORDER}\",\n")
		RESULT_FILE.write(f"\t\t\"family\": \"{TAX_FAMILY}\",\n")
		RESULT_FILE.write(f"\t\t\"genus\": \"{TAX_GENUS}\",\n")
		RESULT_FILE.write(f"\t\t\"species\": \"{TAX_SPECIES}\",\n")
		RESULT_FILE.write(f"\t\t\"strain\": \"{TAX_STRAIN}\"\n")

	elif STATUS == 'disagree':
		RESULT_FILE.write(f"\t\t\"contamination\": \"true\"")
	
	else:
		RESULT_FILE.write("\t\t\"classification failed\": \"true\" ")
	
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def status_parsing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Status\": \"analysed\"\n")	#no comma after this line, because last line of the file
	RESULT_FILE.close()
	return RESULT_FILE

def json_file_closing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("}")
	RESULT_FILE.close()
	return RESULT_FILE

def json_file_closing_deep(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("}]")
	RESULT_FILE.close()
	return RESULT_FILE


################################################################################
## Function calls

DATE = os.popen('date -I | tr -d "-" |tr -d "\n"')					#create bash-output of parsed date
ANALYSING_DATE = DATE.read()										#interpret bash-output in python

if DEEP_JSON == 'false':
	json_file_opening(OUTPUT_FILE_NAME)										#trigger function 'json_file_opening' with according input
else:
	json_file_opening_deep(OUTPUT_FILE_NAME)

if NEW_ENTRY != 'false':
	sample_id_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)
else:
	hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)

if ABRICATE_INPUT != 'false':
	ABRICATE_RESULT_FILE = glob(ABRICATE_INPUT.split(',')[0])[0]		#split abricate-input by ',' taking the first resulting element -> glob expands the wildcard "*", choosing the first result
	ABRICATE_INFO_FILE = glob(ABRICATE_INPUT.split(',')[1])[0]		#split abricate-input by ',' taking the second resulting element
	DF_ABRICATE = pd.read_csv(ABRICATE_RESULT_FILE, sep = '\t')				#create pandas-dataframe from abricate-file with tab-stop as separator

	abricate_info_parsing(OUTPUT_FILE_NAME, ANALYSING_DATE)
	
	if DEEP_JSON == 'false':
		abricate_result_parsing(OUTPUT_FILE_NAME, DF_ABRICATE)
	else:
		abricate_result_parsing_deep(OUTPUT_FILE_NAME, DF_ABRICATE)

if BAKTA_INPUT != 'false':
	BAKTA_FILE = glob(BAKTA_INPUT.split(',')[0])[0]
	BAKTA_VERSION_FILE = glob(BAKTA_INPUT.split(',')[1])[0]
	DF_BAKTA = pd.read_csv(BAKTA_FILE, skiprows=2, sep = '\t')
	
	bakta_info_parsing(OUTPUT_FILE_NAME, BAKTA_VERSION_FILE, ANALYSING_DATE)
	bakta_result_parsing(OUTPUT_FILE_NAME, DF_BAKTA)

if PROKKA_INPUT != 'false':
	PROKKA_FILE = glob(PROKKA_INPUT.split(',')[0])[0]
	PROKKA_VERSION_FILE = glob(PROKKA_INPUT.split(',')[1])[0]
	DF_PROKKA = pd.read_csv(PROKKA_FILE, sep = '\t')

	prokka_info_parsing(OUTPUT_FILE_NAME, PROKKA_VERSION_FILE, ANALYSING_DATE)
	prokka_result_parsing(OUTPUT_FILE_NAME, DF_PROKKA)

if SOURMASH_INPUT != 'false':
	SOURMASH_FILE = glob(SOURMASH_INPUT.split(',')[0])[0]
	SOURMASH_VERSION_FILE = glob(SOURMASH_INPUT.split(',')[1])[0]
	DF_SOURMASH = pd.read_csv(SOURMASH_FILE)

	sourmash_info_parsing(OUTPUT_FILE_NAME, SOURMASH_VERSION_FILE, ANALYSING_DATE)
	sourmash_result_parsing(OUTPUT_FILE_NAME, DF_SOURMASH)

status_parsing(OUTPUT_FILE_NAME)

if DEEP_JSON == 'false':
	json_file_closing(OUTPUT_FILE_NAME)
else:
	json_file_closing_deep(OUTPUT_FILE_NAME)