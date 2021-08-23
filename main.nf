#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* Nextflow -- Genome Analysis Pipeline
* Author: CaSe-group
*/

/************************** 
* HELP messages & checks
**************************/

header()

/* 
Nextflow version check  
Format is this: XX.YY.ZZ  (e.g. 20.07.1)
change below
*/

XX = "21"
YY = "04"
ZZ = "0"

if ( nextflow.version.toString().tokenize('.')[0].toInteger() < XX.toInteger() ) {
println "\033[0;33mgenome_to_json requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}
else if ( nextflow.version.toString().tokenize('.')[1].toInteger() == XX.toInteger() && nextflow.version.toString().tokenize('.')[1].toInteger() < YY.toInteger() ) {
println "\033[0;33mgenome_to_json requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}


// Log infos based on user inputs
if ( params.help ) { exit 0, helpMSG() }


// profile helps
if (params.profile) { exit 1, "--profile is WRONG use -profile" }


// params help
if (!workflow.profile.contains('test_fasta') && !params.fasta) { exit 1, "Input missing, use [--fasta]" }

// check that input params are used as such
if (params.fasta == true) { exit 5, "Please provide a fasta file via [--fasta]" }


/************************** 
* INPUTs
**************************/

// fasta input 
    if ( params.fasta && !workflow.profile.contains('test_fasta') ) { fasta_input_raw_ch = Channel
        .fromPath( params.fasta, checkIfExists: true)
    }


/************************** 
* Log-infos
**************************/

defaultMSG()


/************************** 
* MODULES
**************************/

include { get_fasta } from './modules/get_fasta_test_data.nf'
include { split_fasta } from './modules/split_fasta.nf'


/************************** 
* Workflows
**************************/

include { annotation_wf } from './workflows/annotation_wf.nf'
include { create_json_entries_wf } from './workflows/create_json_entries_wf.nf'
include { resistance_determination_wf } from './workflows/resistance_determination_wf.nf'
include { taxonomic_classification_wf } from './workflows/taxonomic_classification_wf.nf'


/************************** 
* Processes
**************************/

include { abricate } from './workflows/process/abricate.nf'
include { prokka } from './workflows/process/prokka.nf'

/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    // 1. fasta-input
    if ( workflow.profile.contains('test_fasta') ) { fasta_input_raw_ch =  get_fasta() }

    if ( params.fasta || workflow.profile.contains('test_fasta') ) {
        if ( !params.split_fasta ) {
            fasta_input_ch = fasta_input_raw_ch
            .map { it -> tuple(it.baseName, it) }
        }
        else {
            fasta_input_ch = split_fasta(fasta_input_raw_ch)
            .flatten()
            .map { it -> tuple(it.baseName, it) }
        }
    }

    // 2. Genome-analysis (Abricate, Prokka, Sourmash)
    annotation_wf(fasta_input_ch)
    resistance_determination_wf(fasta_input_ch)
    taxonomic_classification_wf(fasta_input_ch)

    // 3. json-output
    create_json_entries_wf(resistance_determination_wf.out, annotation_wf.out, taxonomic_classification_wf.out)
}


/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    .    
\033[0;33mUsage examples:${c_reset}
    nextflow run CaSe-group/genome_to_json --fasta '/path/to/fasta'

${c_yellow}Input:${c_reset}
    --fasta         direct input of genomes - supports multi-fasta file(s)
    
${c_yellow}Options:${c_reset}
    --abricate_off  turns off abricate-process
    --prokka_off    turns off prokka-process
    --sourmash_off  turns off sourmash-process
    
    --split_fasta   splits multi-line fastas into single fasta-files
    --new_entry     activates parsing of sample-name as sample-ID instead of hash-ID (therefore json can be uploaded as new entry)

${c_yellow}Test profile:${c_reset}
    [-profile]-option "test_fasta" runs the test profile using a fasta-file,
    ignoring regular [--fasta]-input
    """.stripIndent()
}

def defaultMSG() {
    log.info """
    \u001B[32mProfile:             $workflow.profile\033[0m
    \033[2mCurrent User:        $workflow.userName
    Nextflow-version:    $nextflow.version
    \u001B[1;30m______________________________________\033[0m
    Pathing:
    \033[2mWorkdir location [-work-Dir]:
        $workflow.workDir
    Output dir [--output]: 
        $params.output
    \u001B[1;30m______________________________________\033[0m
    Parameters:
        \033[2mAbricate switched off:  $params.abricate_off
        Prokka switched off:    $params.prokka_off
        Sourmash switched off:  $params.sourmash_off

        Split fastas:           $params.split_fasta
        New entry:              $params.new_entry
    \u001B[1;30m______________________________________\033[0m
    """.stripIndent()

}

def header(){
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    log.info """
________________________________________________________________________________
    
${c_green}genome_to_json${c_reset} | A Nextflow analysis workflow for fasta-genomes
    """
}
