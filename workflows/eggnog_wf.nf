include { eggnog_db_download } from './process/eggnog.nf'
include { eggnog_emapper } from './process/eggnog.nf'

workflow eggnog_wf {
    take:
        fasta //tuple val(NAME), path({NAME}.fasta)
    main:   
        if (!params.eggnog_off) { 
            eggnog_db_download
            eggnog_emapper(fasta)
        }
        else {
            eggnog_output_ch = Channel.empty()
            eggnog_report = Channel.empty()
        }
    //emit:
        //to_json = busco_json_ch 
        //to_report = busco_rep_ch
}