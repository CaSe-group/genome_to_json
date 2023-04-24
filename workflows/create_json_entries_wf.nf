include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate    //tuple val(fasta-basename) path(abricate_db_version.txt) path(abricate_file) 
        bakta      //tuple val(fasta-basename) path(bakta_file) path(bakta_version.txt)
        prokka      //tuple val(fasta-basename) path(prokka_file) path(prokka_version.txt)
        sourmash    //tuple val(fasta-basename) path(sourmash_file) path(sourmash_version.txt)
    main:
        merged_ch = abricate.concat(bakta, prokka, sourmash).groupTuple(by: 0).map{ it -> tuple (it[0], tuple (it[1],it[2],it[3],it[4]).flatten()) }
        //merged_ch.view() //tuple val(fasta-basename) path(analysis_result-files)
        json_report(merged_ch)
}