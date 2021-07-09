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

include { abricate_wf } from './workflows/process/abricate_wf.nf'
include { create_json_entries_wf } from './workflows/create_json_entries.nf'


/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    // 1. fasta-input
    if ( workflow.profile.contains('test_fasta') ) { fasta_input_raw_ch =  get_fasta() }

    if ( params.multifasta ) {
        if ( params.fasta || workflow.profile.contains('test_fasta') ) { fasta_input_ch = split_fasta(fasta_input_raw_ch).flatten().map { it -> tuple(it.simpleName, it) } }
    }
    else { fasta_input_ch = fasta_input_raw_ch.flatten().map { it -> tuple(it.simpleName, it) } }

    // 2. Genome-analysis (Abricate, Prokka, Sourmash)
    abricate_output_ch = abricate_wf(fasta_input_ch)
    
    if ( !params.prokka_off) { prokka_output_ch = fasta_input_ch.map{ it -> tuple(it[0]) }.combine(Channel.fromPath(workflow.projectDir + "/data/prokka_placeholder.csv")) }
    else { prokka_output_ch = fasta_input_ch.map{ it -> tuple(it[0]) }.combine(Channel.fromPath(workflow.projectDir + "/data/prokka_placeholder.csv")) }
    
    if ( !params.sourmash_off) { sourmash_output_ch = fasta_input_ch.map{ it -> tuple(it[0]) }.combine(Channel.fromPath(workflow.projectDir + "/data/sourmash_placeholder.csv")) }
    else { sourmash_output_ch = fasta_input_ch.map{ it -> tuple(it[0]) }.combine(Channel.fromPath(workflow.projectDir + "/data/sourmash_placeholder.csv")) }

    // 3. json-output
    create_json_entries_wf(abricate_output_ch, prokka_output_ch, sourmash_output_ch)
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
    """.stripIndent()
}

def defaultMSG() {
    log.info """
    .
    \u001B[32mProfile:             $workflow.profile\033[0m
    \033[2mCurrent User:        $workflow.userName
    Nextflow-version:    $nextflow.version
    \u001B[0m
    Pathing:
    \033[2mWorkdir location [-work-Dir]:
        $workflow.workDir
    Output dir [--output]: 
        $params.output
    \u001B[1;30m______________________________________\033[0m
    Parameters:
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