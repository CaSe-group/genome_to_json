include { busco } from './process/busco.nf'

workflow busco_wf {
    take:
        fasta_sourmash //tuple val(NAME), path({NAME}.fasta)
        sourmash_output //tuple val(NAME), path({NAME}_taxonomy.tsv), val(SOURMASH_VERSION))
    main:   
        if (params.bakta_db) { database_bakta = file(params.bakta_db) }
                    
        if (!params.busco_off) { 
            if (!params.sourmash_off) {busco(fasta_input, sourmash_output) }
            else { busco(fasta_input) }
        else {
            busco_output_ch = Channel.empty()
            busco_report = Channel.empty()
        }
    emit:
        to_json = busco_json_ch 
        to_report = busco_rep_ch
}