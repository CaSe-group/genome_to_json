include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate    //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version)
        prokka      //tuple val(fasta_basename) path(prokka_file) val(prokka_version)
        sourmash    //tuple val(fasta_basename) path(sourmash_file)
    main:
        merged_ch = abricate.join(prokka.join(sourmash)) 
        //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version) path(prokka_file) val(prokka_version) path(sourmash_file)
        
        json_report(merged_ch)
} 
