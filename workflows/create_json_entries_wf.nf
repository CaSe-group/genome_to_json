include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate    //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version)
        bakta      //tuple val(fasta_basename) path(bakta_file) val(bakta_version)
        prokka      //tuple val(fasta_basename) path(prokka_file) val(prokka_version)
        sourmash    //tuple val(fasta_basename) path(sourmash_file)
    main:
        merged_ch = abricate.mix(bakta, prokka, sourmash).groupTuple(by: 0).map{ it -> tuple (it[0], tuple (it[1],it[2]).flatten()) }
        merged_ch.view()
        //tuple val(fasta_basename) path(analysis_result_files)
        //json_report(merged_ch)
}