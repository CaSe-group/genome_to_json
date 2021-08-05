#!/usr/bin/env python3
# Original code by Sebastian Krautwurst. Improved by Riccardo Spott.

################################################################################
## Module-import

import os
import sys
import fnmatch


################################################################################
## Function-definition

def error(STRING, ERROR_TYPE=1):                                            #define error-code-function taking string and error-type (default = 1)
    sys.stderr.write(f'ERROR: {STRING}\n')                                  #write string to stderr
    sys.exit(ERROR_TYPE)                                                    #exit code with error-type

def log(STRING, NEWLINE_BEFORE=False):                                      #define log-function taking string and newline-before boolean (default = False)
    if NEWLINE_BEFORE:                                                      #if there is a new line before
        sys.stderr.write('\n')                                              #write a new line in stderr
    sys.stderr.write(f'LOG: {STRING}\n')                                    #write string to stderr 


################################################################################
## Script

SEQUENCE_NAMES = []                                                         #create empty list
OUTPUT_FILE = None                                                          #set variable

for FASTA_FILE in sys.argv[1:]:                                             #for-loop over all fasta-files given in the command-line after the program-call

    if not os.path.exists(FASTA_FILE):                                      #check if fasta-file exists
        error(f'Not a file: {FASTA_FILE}')                                  #if False trigger error-function

    log(f'Reading {FASTA_FILE} ...')                                        #trigger log-function
    with open(FASTA_FILE) as IN_FILE:                                       #open fasta-file under variable IN_FILE
        for LINE in IN_FILE:                                                #for-loop over all lines of IN_FILE
            if LINE.startswith('>'):

                # new sequence
                SEQ_NAME = LINE.strip().split()[0][1:]                      #remove leading/tailing whitespaces from LINE, split it by each whitespace
                                                                            #and take only the first element beginning from the second character
                assert SEQ_NAME != '', f'Empty header in file: {FASTA_FILE}'#check if SEQ_NAME and therefore the strip-splitted-fasta header is empty
                
                # sanitize
                SEQ_NAME = SEQ_NAME.replace('/', '_').replace(':', '_').replace('|','_')    #replace all '/',':' & '|' with '_' in SEQ_NAME

                # handle duplicates
                if SEQ_NAME in SEQUENCE_NAMES:                              #check if SEQ_NAME is in list SEQUENCE_NAMES
                    log(f'WARNING: Duplicate sequence name: {SEQ_NAME}')    #trigger log-function
                    # add number to SEQ_NAME, according to how often SEQ_NAME already appeared
                    DUPLICATE_SEQ_NAME_PATTERN = f'{SEQ_NAME}_duplicate*'   #create search-pattern from SEQ_NAME utilizing bash-wildstar
                    SEQ_NAME += f'_duplicate{int(len([ITEM for ITEM in SEQUENCE_NAMES if ITEM == SEQ_NAME or fnmatch.fnmatch(ITEM ,DUPLICATE_SEQ_NAME_PATTERN)])):02d}'
                                                                            #list-comprehension over all items in list SEQUENCE_NAMES checking if item equals SEQ_NAME or matches the search-pattern /
                                                                            #-> if True takes length of resulting list as integer with 2 characters and attaches it as '_duplicate??' to SEQ_NAME/
                                                                            #-> e.g., 3 times SEQ_NAME(_duplicate??) in list SEQUENCE_NAMES -> list of 3 items-> len = 3 -> int(3):02d = 03 -> SEQ_NAME_duplicate03
                # save
                SEQUENCE_NAMES.append(SEQ_NAME)                             #add SEQ_NAME to end of list SEQUENCES_NAMES

                # write to separate file
                if OUTPUT_FILE is not None:
                    OUTPUT_FILE.close()                                     #if True close OUTPUT_FILE
                OUTPUT_FILE_NAME = 'split_fasta/' + SEQ_NAME + '.fasta'     #create OUTPUT_FILE_NAME from SEQ_NAME & strings
                log(f'Writing {OUTPUT_FILE_NAME}')                          #trigger log-function
                OUTPUT_FILE = open(OUTPUT_FILE_NAME, 'w')                   #open a file named OUTPUT_FILE_NAME with write-access under variable OUTPUT_FILE
                OUTPUT_FILE.write(f'>{SEQ_NAME}\n')                         #write SEQ_NAME as part of a string into OUTPUT_FILE
                
            else:
                # write rest of lines (and fix windows line endings)
                OUTPUT_FILE.write(LINE.replace('\r',''))                    #write each LINE not starting with '>' into OUTPUT_FILE after replacing Windows line-endings

        # done for this file
        OUTPUT_FILE.close()                                                 #close OUTPUT_FILE

log('Done.')                                                                #trigger log-function
