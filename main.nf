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
if ( params.profile ) { exit 1, "[--profile] is WRONG use [-profile]." }

// params help
if ( !workflow.profile.contains('test_fasta') && !params.fasta ) { exit 1, "Input missing, use [--fasta]." }

// check that input params are used as such
if ( params.fasta == true ) { exit 2, "Please provide a fasta file via [--fasta]." }

if ( params.busco_db == true ) { exit 3, "Please provide a complete busco-database name (with \"tar.gz\"-ending) via [--busco_db]." }

// check that at least one tool is active
if ( !params.abricate && !params.bakta && !params.busco && !params.eggnog && !params.pgap && !params.prokka && !params.sourmash ) {
    exit 3, "All tools deactivated. Please activate at least one tool."
}
// check if PGAP is run the species parameter was specified 
if ( params.pgap && !params.species ) { exit 1, "Please provide the species in a NCBI notation to run PGAP." }

// Use pgap profile for working with pgap
 if ( params.pgap && workflow.profile.contains ("ukj_cloud")) {
    exit 1, "Please use pgap_cloud profile [-profile pgap_cloud]."
 }

// Use ukj_cloud profile if you are not working with pgap
 if ( !params.pgap && workflow.profile.contains ("pgap_cloud")) {
    exit 1, "Please use ukj_cloud profile [-profile ukj_cloud]."
 }
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
if ( params.busco) {
    buscoDb_InfoMSG()
}


/************************** 
* MODULES
**************************/

include { get_fasta } from './modules/get_fasta_test_data.nf'
include { split_fasta } from './modules/split_fasta.nf'


/************************** 
* Workflows
**************************/

include { abricate_wf } from './workflows/abricate_wf.nf'
include { bakta_wf } from './workflows/bakta_wf'
include { busco_wf } from './workflows/busco_wf'
include { collect_fasta_wf } from './workflows/collect_fasta_wf.nf'
include { create_json_entries_wf } from './workflows/create_json_entries_wf.nf'
include { eggnog_wf } from './workflows/eggnog_wf.nf'
include { pgap_wf } from './workflows/pgap_wf.nf'
include { prokka_wf } from './workflows/prokka_wf.nf'
include { report_generation_full_wf } from './workflows/report_wf.nf'
include { sourmash_wf } from './workflows/sourmash_wf.nf'


/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    // 1. fasta-input
    if ( workflow.profile.contains('test_fasta') ) { fasta_input_raw_ch =  get_fasta() }

    if ( params.fasta || workflow.profile.contains('test_fasta') ) {
        fasta_input_ch = collect_fasta_wf(fasta_input_raw_ch)

        if ( !params.split_fasta ) {
            fasta_ch = fasta_input_ch
                        .map { it -> tuple(it.baseName, it) }
        }
        else {
            fasta_ch = split_fasta(fasta_input_ch)
                        .flatten()
                        .map { it -> tuple(it.baseName, it) }
        }
    }

    // 2. Genome-analysis (Abricate, Bakta, Prokka, Sourmash)
    abricate_wf(fasta_ch) // Resistance-determination
    bakta_wf(fasta_ch) // Annotation
    busco_wf(fasta_ch) // Housekeeping-gene screening to assume genome-completeness
    eggnog_wf(fasta_ch) // Annotation
    prokka_wf(fasta_ch) // Annotation
    pgap_wf(fasta_ch, params.species) // Annotation
    sourmash_wf(fasta_ch) // Taxonomic-classification

    // 3. json-output
    if ( !params.no_json ) {
        create_json_entries_wf( 
            abricate_wf.out.to_json,
            bakta_wf.out.to_json,
            busco_wf.out.to_json,
            prokka_wf.out.to_json,
            sourmash_wf.out.to_json
        )
    }

    // 4. report
    if ( !params.no_html) {
        report_generation_full_wf( 
            abricate_wf.out.to_report,
            bakta_wf.out.to_report,
            busco_wf.out.to_report,
            eggnog_wf.out.to_report,
            pgap_wf.out.to_report,
            prokka_wf.out.to_report,
            sourmash_wf.out.to_report
        )
    }
}


/*************  
* MSG
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    
\033[0;33mUsage examples:${c_reset}
    nextflow run CaSe-group/genome_to_json --fasta '/path/to/fasta' --abricate

${c_yellow}Input:${c_reset}
    --fasta         direct input of genomes - also supports multi-fasta file(s),
                    .xz-packed fasta-files & input of a directory containing 
                    fasta-files

${c_yellow}General options:${c_reset}
    --new_entry     activates parsing of sample-name as sample-ID instead of
                    hash-ID (therefore json can be uploaded as new entry)
    --no_html       deactivates output of final HTML-Report
    --no_json       deactivates output of json-files
    --split_fasta   splits multi-line fastas into single fasta-files

${c_yellow}Tool switches:${c_reset}
    --abricate  turns on abricate-process
    --bakta     turns on bakta-process
    --busco     turns on busco-process
    --eggnog    turns on eggnog-process
    --pgap      turns on pgap-process [requires "--species"-flag]
    --prokka    turns on prokka-process
    --sourmash  turns on sourmash-process

${c_yellow}Tool options:${c_reset}
    --abricate_coverage sets the coverage value [%] that ABRicate shall use
                        \033[2m[Default: "80 %"]\033[0m
    --abricate_identity sets the identity value [%] that ABRicate shall use
                        \033[2m[Default: "80 %"]\033[0m
    --abricate_update   forces an update for all databases used by ABRicate
    --bakta_db      path to your own bakta DB instead (.tar.gz)
    --busco_db      choose a busco-database (full name) from
                    "https://busco-data.ezlab.org/v5/data/lineages/"
                    \033[2m[Default: "bacteria_odb10.2020-03-06.tar.gz"]\033[0m
    --pgap_db       path to your own pgap DB instead
    --species       species in NCBI notation; required to run PGAP

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
        \033[2mAbricate switched on:    $params.abricate
        Bakta switched on:      $params.bakta
        Busco switched on:      $params.busco
        Eggnog switched on:     $params.eggnog
        PGAP switched on:       $params.pgap
        Prokka switched on:     $params.prokka
        Sourmash switched on:   $params.sourmash

        New entry:              $params.new_entry
        Split fastas:           $params.split_fasta
    \u001B[1;30m______________________________________\033[0m
    """.stripIndent()

}

def header(){
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    log.info """
________________________________________________________________________________
    
${c_green}genome_to_json${c_reset} | A Nextflow analysis workflow for bacteria genome-analysis from fastas
    """
}

def buscoDb_InfoMSG() {
    log.info """
    Busco-database:
        \033[2mUsing Busco-db:  $params.busco_db
    \u001B[1;30m______________________________________\033[0m
    """.stripIndent()
}
