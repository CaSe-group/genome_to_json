include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate    //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version)
        bakta   //tuple val(fasta_basename) path(bakta_file) val(bakta_version)
        sourmash    //tuple val(fasta_basename) path(sourmash_file)
        gtdb    //tuple val(fasta_basename) path(gtdb_result_dir)
    main:
        merged_ch = abricate.join(bakta.join(sourmash.join(gtdb))) 
        //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version) path(bakta_file) val(bakta_version) path(sourmash_file) val(sourmash_version) path(gtdb_result_dir)
        json_report(merged_ch)
}