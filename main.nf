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


// check that input params are used as such
if (params.fasta == true) { exit 5, "Please provide a fasta file via [--fasta]" }


/************************** 
* INPUTs
**************************/

// fasta input 
    if ( params.fasta ) { fasta_input_raw_ch = Channel
        .fromPath( params.fasta, checkIfExists: true)
    }


/************************** 
* Log-infos
**************************/

defaultMSG()


/************************** 
* MODULES
**************************/

include { split_fasta } from './modules/split_fasta.nf'


/************************** 
* Workflows
**************************/

//include { } from './workflows/'


/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    if ( params.fasta ) { fasta_input_ch = split_fasta(fasta_input_raw_ch).flatten().map { it -> tuple(it.simpleName, it) } }
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