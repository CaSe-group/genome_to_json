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
parser.add_argument('-c', '--busco', help = "Input Busco-files", default = 'false')
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
BUSCO_INPUT = arg.busco
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

def abricate_info_parsing(OUTPUT_FILE_NAME, IN_ABRICATE_INFO_FILE, ANALYSING_DATE):
	ABRICATE_INFO_FILE_ALL_LINES = open(f"{IN_ABRICATE_INFO_FILE}", "r").readlines()
	ABRICATE_VERSION = ':'.join(ABRICATE_INFO_FILE_ALL_LINES[0].split(':')[1:]).strip()
	ABRICATE_DB_VERSION = ':'.join(ABRICATE_INFO_FILE_ALL_LINES[1].split(':')[1:]).strip()
	ABRICATE_COMMAND = ':'.join(ABRICATE_INFO_FILE_ALL_LINES[2].split(':')[1:]).strip()
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Abricate_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Abricate_Version\": \"{ABRICATE_VERSION}\",\n")
	RESULT_FILE.write(f"\t\t\"Abricate_Db_Version\": \"{ABRICATE_DB_VERSION}\",\n")
	RESULT_FILE.write(f"\t\t\"Abricate_Command\": \"{ABRICATE_COMMAND}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_result_parsing(OUTPUT_FILE_NAME, IN_ABRICATE_RESULT_FILE):
	DF_ABRICATE = pd.read_csv(IN_ABRICATE_RESULT_FILE, sep = '\t')			#create pandas-dataframe from abricate-file with tab-stop as separator
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

def abricate_result_parsing_deep(OUTPUT_FILE_NAME, IN_ABRICATE_RESULT_FILE):
	DF_ABRICATE = pd.read_csv(IN_ABRICATE_RESULT_FILE, sep = '\t')
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

def bakta_info_parsing(OUTPUT_FILE_NAME, IN_BAKTA_INFO_FILE, ANALYSING_DATE):
	BAKTA_VERSION = open(f"{IN_BAKTA_INFO_FILE}", "r").read().replace("\n","")
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Bakta_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Bakta_Version\": \"{BAKTA_VERSION}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def bakta_result_parsing(OUTPUT_FILE_NAME, IN_BAKTA_RESULT_FILE):
	DF_BAKTA = pd.read_csv(IN_BAKTA_RESULT_FILE, skiprows=2, sep = '\t')
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

def busco_info_parsing(OUTPUT_FILE_NAME, IN_BUSCO_INFO_FILE, ANALYSING_DATE):
	BUSCO_INFO_FILE_ALL_LINES = open(f"{IN_BUSCO_INFO_FILE}", "r").readlines()
	BUSCO_VERSION = ':'.join(BUSCO_INFO_FILE_ALL_LINES[0].split(':')[1:]).strip()
	BUSCO_DB_VERSION = ':'.join(BUSCO_INFO_FILE_ALL_LINES[1].split(':')[1:]).strip()
	BUSCO_COMMAND = ':'.join(BUSCO_INFO_FILE_ALL_LINES[2].split(':')[1:]).strip()
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Busco_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Busco_Version\": \"{BUSCO_VERSION}\",\n")
	RESULT_FILE.write(f"\t\t\"Busco_Db_Version\": \"{BUSCO_DB_VERSION}\",\n")
	RESULT_FILE.write(f"\t\t\"Busco_Command\": \"{BUSCO_COMMAND}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def busco_result_parsing(OUTPUT_FILE_NAME, IN_BUSCO_RESULT_FILE):
	DF_BUSCO = pd.read_csv(IN_BUSCO_RESULT_FILE, sep = '\t')
	BUSCO_TOTAL = len(DF_BUSCO)
	BUSCO_COMPLETE_SINGLE = len(DF_BUSCO[DF_BUSCO['Status'] == 'Complete'])
	BUSCO_COMPLETE_DUPLICATE = len(DF_BUSCO[DF_BUSCO['Status'] == 'Duplicated'])
	BUSCO_FRAGMENTED = len(DF_BUSCO[DF_BUSCO['Status'] == 'Fragmented'])
	BUSCO_MISSING = len(DF_BUSCO[DF_BUSCO['Status'] == 'Missing'])
	BUSCO_COMPLETE_ADDED = BUSCO_COMPLETE_SINGLE + BUSCO_COMPLETE_DUPLICATE
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"\t\"Busco_Result\": \"Total: {BUSCO_TOTAL}; Complete:{BUSCO_COMPLETE_ADDED} [Single: {BUSCO_COMPLETE_SINGLE}, Duplicate: {BUSCO_COMPLETE_DUPLICATE}]; Fragmented: {BUSCO_FRAGMENTED}; Missing: {BUSCO_MISSING}\",\n")
	RESULT_FILE.close()
	return RESULT_FILE

def busco_result_parsing_deep(OUTPUT_FILE_NAME, IN_BUSCO_RESULT_FILE):
	DF_BUSCO = pd.read_csv(IN_BUSCO_RESULT_FILE, sep = '\t')
	BUSCO_ID_LIST = DF_BUSCO['Busco_id'].values
	BUSCO_STATUS_LIST = DF_BUSCO['Status'].values
	BUSCO_SEQUENCE_LIST = DF_BUSCO['Sequence'].values
	BUSCO_GENE_START_LIST = DF_BUSCO['Gene Start'].values
	BUSCO_GENE_END_LIST = DF_BUSCO['Gene End'].values
	BUSCO_GENE_STRAND_LIST = DF_BUSCO['Strand'].values
	BUSCO_GENE_SCORE_LIST = DF_BUSCO['Score'].values
	BUSCO_GENE_LENGTH_LIST = DF_BUSCO['Length'].values
	BUSCO_GENE_URL_LIST = DF_BUSCO['OrthoDB url'].values
	BUSCO_GENE_DESCRIPTION_LIST = DF_BUSCO['Description'].values
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Busco_Result\": {\n")
	[RESULT_FILE.write(f"\t\t\"{BUSCO_ID_LIST[INDEX]}\": {{\n\t\t\t\"Status\": \"{BUSCO_STATUS_LIST[INDEX]}\",\n\t\t\t\"Sequence\": \"{BUSCO_SEQUENCE_LIST[INDEX]}\",\n\t\t\t\"Gene_Start\": \"{BUSCO_GENE_START_LIST[INDEX]}\",\n\t\t\t\"Gene_End\": \"{BUSCO_GENE_END_LIST[INDEX]}\",\n\t\t\t\"Gene_Strand\": \"{BUSCO_GENE_STRAND_LIST[INDEX]}\",\n\t\t\t\"Score\": \"{BUSCO_GENE_SCORE_LIST[INDEX]}\",\n\t\t\t\"Length\": \"{BUSCO_GENE_LENGTH_LIST[INDEX]}\",\n\t\t\t\"URL\": \"{BUSCO_GENE_URL_LIST[INDEX]}\",\n\t\t\t\"Description\": \"{BUSCO_GENE_DESCRIPTION_LIST[INDEX]}\"}},\n") if BUSCO_ID_LIST[INDEX] != BUSCO_ID_LIST[-1] else RESULT_FILE.write(f"\t\t\"{BUSCO_ID_LIST[INDEX]}\": {{\n\t\t\t\"Status\": \"{BUSCO_STATUS_LIST[INDEX]}\",\n\t\t\t\"Sequence\": \"{BUSCO_SEQUENCE_LIST[INDEX]}\",\n\t\t\t\"Gene_Start\": \"{BUSCO_GENE_START_LIST[INDEX]}\",\n\t\t\t\"Gene_End\": \"{BUSCO_GENE_END_LIST[INDEX]}\",\n\t\t\t\"Gene_Strand\": \"{BUSCO_GENE_STRAND_LIST[INDEX]}\",\n\t\t\t\"Score\": \"{BUSCO_GENE_SCORE_LIST[INDEX]}\",\n\t\t\t\"Length\": \"{BUSCO_GENE_LENGTH_LIST[INDEX]}\",\n\t\t\t\"URL\": \"{BUSCO_GENE_URL_LIST[INDEX]}\",\n\t\t\t\"Description\": \"{BUSCO_GENE_DESCRIPTION_LIST[INDEX]}\"}}\n")  for INDEX in range(len(BUSCO_ID_LIST))]
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def prokka_info_parsing(OUTPUT_FILE_NAME, IN_PROKKA_INFO_FILE, ANALYSING_DATE):
	PROKKA_VERSION = open(f"{IN_PROKKA_INFO_FILE}", "r").read().replace("\n","")
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Prokka_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Prokka_Version\": \"{PROKKA_VERSION}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def prokka_result_parsing(OUTPUT_FILE_NAME, IN_PROKKA_RESULT_FILE):
	DF_PROKKA = pd.read_csv(IN_PROKKA_RESULT_FILE, sep = '\t')
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

def sourmash_info_parsing(OUTPUT_FILE_NAME, IN_SOURMASH_INFO_FILE, ANALYSING_DATE):
	SOURMASH_VERSION = open(f"{IN_SOURMASH_INFO_FILE}", "r").read().replace("\n","")
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("\t\"Sourmash_Info\": {\n")
	RESULT_FILE.write(f"\t\t\"Analysing_Date\": {ANALYSING_DATE},\n")
	RESULT_FILE.write(f"\t\t\"Sourmash_Version\": \"{SOURMASH_VERSION}\"\n")
	RESULT_FILE.write("\t},\n")
	RESULT_FILE.close()
	return RESULT_FILE

def sourmash_result_parsing(OUTPUT_FILE_NAME, IN_SOURMASH_RESULT_FILE):
	DF_SOURMASH = pd.read_csv(IN_SOURMASH_RESULT_FILE)
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
	

	abricate_info_parsing(OUTPUT_FILE_NAME, ABRICATE_INFO_FILE, ANALYSING_DATE)
	
	if DEEP_JSON == 'false':
		abricate_result_parsing(OUTPUT_FILE_NAME, ABRICATE_RESULT_FILE)
	else:
		abricate_result_parsing_deep(OUTPUT_FILE_NAME, ABRICATE_RESULT_FILE)

if BAKTA_INPUT != 'false':
	BAKTA_RESULT_FILE = glob(BAKTA_INPUT.split(',')[0])[0]
	BAKTA_INFO_FILE = glob(BAKTA_INPUT.split(',')[1])[0]
	
	bakta_info_parsing(OUTPUT_FILE_NAME, BAKTA_INFO_FILE, ANALYSING_DATE)
	bakta_result_parsing(OUTPUT_FILE_NAME, BAKTA_RESULT_FILE)

if BUSCO_INPUT != 'false':
	BUSCO_RESULT_FILE = glob(BUSCO_INPUT.split(',')[0])[0]
	BUSCO_INFO_FILE = glob(BUSCO_INPUT.split(',')[1])[0]

	busco_info_parsing(OUTPUT_FILE_NAME, BUSCO_INFO_FILE, ANALYSING_DATE)
	
	if DEEP_JSON == 'false':
		busco_result_parsing(OUTPUT_FILE_NAME, BUSCO_RESULT_FILE)
	else:
		busco_result_parsing_deep(OUTPUT_FILE_NAME, BUSCO_RESULT_FILE)

if PROKKA_INPUT != 'false':
	PROKKA_RESULT_FILE = glob(PROKKA_INPUT.split(',')[0])[0]
	PROKKA_INFO_FILE = glob(PROKKA_INPUT.split(',')[1])[0]

	prokka_info_parsing(OUTPUT_FILE_NAME, PROKKA_INFO_FILE, ANALYSING_DATE)
	prokka_result_parsing(OUTPUT_FILE_NAME, PROKKA_RESULT_FILE)

if SOURMASH_INPUT != 'false':
	SOURMASH_RESULT_FILE = glob(SOURMASH_INPUT.split(',')[0])[0]
	SOURMASH_INFO_FILE = glob(SOURMASH_INPUT.split(',')[1])[0]

	sourmash_info_parsing(OUTPUT_FILE_NAME, SOURMASH_INFO_FILE, ANALYSING_DATE)
	sourmash_result_parsing(OUTPUT_FILE_NAME, SOURMASH_RESULT_FILE)

status_parsing(OUTPUT_FILE_NAME)

if DEEP_JSON == 'false':
	json_file_closing(OUTPUT_FILE_NAME)
else:
	json_file_closing_deep(OUTPUT_FILE_NAME)