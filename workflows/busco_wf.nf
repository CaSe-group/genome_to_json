include { busco } from './process/busco.nf'
include { busco_db_download } from './process/busco.nf'

workflow busco_wf {
    take:
        fasta //tuple val(name), path(fasta-file)
    main:   
        if ( params.busco ) {
            busco_db_download()
            busco(fasta, busco_db_download.out.busco_db_ch)
            busco_output_ch = busco.out.busco_file_output_ch
            busco_report_ch = busco.out.busco_report_output_ch
        }
        else {
            busco_output_ch = Channel.empty()
            busco_report_ch = Channel.empty()
        }
    emit:
        to_json = busco_output_ch // tuple val(name), path(busco_info_file), path(busco_result-file)
        to_report = busco_report_ch // tuple val(name), env(BUSCO_VERSION), env(BUSCO_DB_VERSION), env(COMMAND_TEXT), env(PLOT_PERCENTAGE_VALUES), env(PLOT_ABSOLUTE_VALUES), path(busco_result-file)
}