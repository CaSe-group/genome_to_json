include { eggnog_db_download } from './process/eggnog.nf'
include { eggnog_emapper } from './process/eggnog.nf'

workflow eggnog_wf {
    take:
        fasta //tuple val(NAME), path({NAME}.fasta)
    main:   
        if ( params.eggnog ) { 
            eggnog_db_download()
            eggnog_emapper(fasta, eggnog_db_download.out)
            eggnog_output_ch = Channel.empty()
            eggnog_report_ch = Channel.empty()
        }
        else {
            eggnog_output_ch = Channel.empty()
            eggnog_report_ch = Channel.empty()
        }
    emit:
        to_json = eggnog_output_ch 
        to_report = eggnog_report_ch
}