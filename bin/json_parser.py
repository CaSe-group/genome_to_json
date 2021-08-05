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

parser.add_argument('-a', '--abricate', help = "Input Abricate-file", default = 'false')
parser.add_argument('-i', '--hashid', help = "Input hashID", required = True)
parser.add_argument('-n', '--new_entry', help = "Activate to generate new entry-json for the db", default = 'false' )
parser.add_argument('-o', '--output', help = "Output-directory", default = os.getcwd())
parser.add_argument('-p', '--prokka', help = "Input Prokka-file", default = 'false')
parser.add_argument('-s', '--sourmash', help = "Input Sourmash-file", default = 'false')

#parsing:
arg = parser.parse_args()

#define arguments as variables:
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
os.makedirs(OUTPUT_PATH, exist_ok = True)

#check if output-flag was used:
if OUTPUT_PATH != os.getcwd():
        
    #change working directory to the path
    os.chdir(OUTPUT_PATH)


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

def sample_id_parsing(OUTPUT_FILE_NAME, HASHID_INPUT):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"SampleID\": \"{HASHID_INPUT}\",\n")
	RESULT_FILE.close()
	return RESULT_FILE

def status_parsing(OUTPUT_FILE_NAME):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Status\": \"analysed\",\n")
	RESULT_FILE.close()
	return RESULT_FILE

def res_gene_parsing(OUTPUT_FILE_NAME, DF_ABRICATE):
	RES_GENE_LIST = DF_ABRICATE['GENE'].values
	if len(RES_GENE_LIST) == 0:
		RES_GENE_LIST = ['no_resistance_genes']
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Resistance_Genes\": {\n")
	[RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\",\n") if RES_GENE != RES_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{RES_GENE}\": \"true\"\n") for RES_GENE in RES_GENE_LIST]
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def abricate_db_version_parsing(OUTPUT_FILE_NAME, ABRICATE_DB_VERSION):
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"Abricate_Db_Version\": \"{ABRICATE_DB_VERSION}\",\n")

def prokka_parsing(OUTPUT_FILE_NAME, DF_PROKKA):
	PROKKA_GENE_LIST = DF_PROKKA['gene'].values
	if 	len(PROKKA_GENE_LIST) == 0:
			PROKKA_GENE_LIST = 'no_genes_detected'
	PROKKA_GENE_LIST = PROKKA_GENE_LIST[~pd.isnull(PROKKA_GENE_LIST)]
	PROKKA_GENE_LIST = np.unique(PROKKA_GENE_LIST)
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write("    \"Genes\": {\n")
	[RESULT_FILE.write(f"        \"{GENE}\": \"true\",\n") if GENE != PROKKA_GENE_LIST[-1] else RESULT_FILE.write(f"        \"{GENE}\": \"true\"\n") for GENE in PROKKA_GENE_LIST]
	RESULT_FILE.write("    },\n")
	RESULT_FILE.close()
	return RESULT_FILE

def sourmash_parsing(OUTPUT_FILE_NAME, DF_SOURMASH):
	status = DF_SOURMASH['status'].values[0]
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	if status == 'found':
		tax_superkingdom = DF_SOURMASH['superkingdom'].values[0]
		tax_phylum = DF_SOURMASH['phylum'].values[0]
		tax_class = DF_SOURMASH['class'].values[0]
		tax_order = DF_SOURMASH['order'].values[0]
		tax_family = DF_SOURMASH['family'].values[0]
		tax_genus = DF_SOURMASH['genus'].values[0]
		tax_species = DF_SOURMASH['species'].values[0]
		tax_strain = DF_SOURMASH['strain'].values[0]
		RESULT_FILE.write("    \"Taxonomy\": {\n")
		RESULT_FILE.write(f"        \"superkingdom\": \"{tax_superkingdom}\",\n")
		RESULT_FILE.write(f"        \"phylum\": \"{tax_phylum}\",\n")
		RESULT_FILE.write(f"        \"class\": \"{tax_class}\",\n")
		RESULT_FILE.write(f"        \"order\": \"{tax_order}\",\n")
		RESULT_FILE.write(f"        \"family\": \"{tax_family}\",\n")
		RESULT_FILE.write(f"        \"genus\": \"{tax_genus}\",\n")
		RESULT_FILE.write(f"        \"species\": \"{tax_species}\",\n")
		RESULT_FILE.write(f"        \"strain\": \"{tax_strain}\"\n")
		RESULT_FILE.write("    },\n")

	elif status == 'disagree':
		RESULT_FILE.write('contamination: true')
	else:
		RESULT_FILE.write("    \"Taxonomy\": {\n")
		RESULT_FILE.write("			\"taxonomy classification failed\": \"true\" ")
		RESULT_FILE.write("    },\n")
	
	RESULT_FILE.close()
	return RESULT_FILE

def analysing_date_parsing(OUTPUT_FILE_NAME):
	DATE = os.popen('date -I | tr -d "-" |tr -d "\n"')
	ANALYSING_DATE = DATE.read()
	RESULT_FILE = open(OUTPUT_FILE_NAME, "a")
	RESULT_FILE.write(f"    \"Analysing_Date\": {ANALYSING_DATE}\n") #no comma after this line, because last line of the file
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

if NEW_ENTRY != 'false':
	sample_id_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)
else:
	hashid_parsing(OUTPUT_FILE_NAME, HASHID_INPUT)

status_parsing(OUTPUT_FILE_NAME)

if ABRICATE_INPUT != 'false':
	ABRICATE_FILE = arg.abricate.split(',')[0]
	ABRICATE_DB_VERSION = arg.abricate.split(',')[1]
	DF_ABRICATE = pd.read_csv(ABRICATE_FILE, sep = '\t')
	
	res_gene_parsing(OUTPUT_FILE_NAME, DF_ABRICATE)
	abricate_db_version_parsing(OUTPUT_FILE_NAME, ABRICATE_DB_VERSION)

if PROKKA_INPUT != 'false':
	DF_PROKKA = pd.read_csv(PROKKA_INPUT, sep = '\t')
	prokka_parsing(OUTPUT_FILE_NAME, DF_PROKKA)

if SOURMASH_INPUT != 'false':
	DF_SOURMASH = pd.read_csv(SOURMASH_INPUT)
	sourmash_parsing(OUTPUT_FILE_NAME, DF_SOURMASH)

analysing_date_parsing(OUTPUT_FILE_NAME)
json_file_closing(OUTPUT_FILE_NAME)
