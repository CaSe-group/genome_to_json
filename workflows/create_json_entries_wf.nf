include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate    //tuple val(fasta_basename) path(abricate_file)
        prokka      //tuple val(fasta_basename) path(prokka_file)
        sourmash    //tuple val(fasta_basename) path(sourmash_file)
    main:
        merged_ch = abricate.join(prokka.map { it -> tuple(it[0], it[1])}.join(sourmash)) 
        //tuple val(fasta_basename) path(abricate_file) path(prokka_file) path(sourmash_file)
        
        json_report(merged_ch)
} 
