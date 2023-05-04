include { abricate; abricate_combiner } from './process/abricate.nf'

workflow abricate_wf {
    take: 
        fasta_input //tuple val(name), path(fasta-file)
    main:
        if ( params.abricate ) {
            if (!params.deep_json) {
                abricate_db = ['ncbi', 'card', 'vfdb', 'ecoh', 'argannot', 'plasmidfinder', 'resfinder'] //define ArrayList with ABRicate-databases to run
                abricate(fasta_input, abricate_db)
                abricate_combiner(abricate.out.abricate_ncbi_ch)
            }
            else {
                abricate_db = ['plasmidfinder', 'resfinder']
                abricate(fasta_input, abricate_db)
                
                abricate_output_ch_raw = abricate.out.abricate_deep_json_ch.groupTuple() // group all outputs of individual "abricate"-processes based on sample-ids
                abricate_combiner(abricate_output_ch_raw)
            }
            abricate_output_ch = abricate_combiner.out.abricate_combiner_file_ch // channel for json-creation
            abricate_report_ch = abricate_combiner.out.abricate_combiner_report_ch // channel for report-creation
        }
        else {
            abricate_output_ch = Channel.empty()
            abricate_report_ch = Channel.empty()
        }
    emit:
        to_json = abricate_output_ch // tuple val(name), path(abricate_info_file), path(abricate_result_file) 
        to_report =  abricate_report_ch // tuple val(name), val(version), val(db_version), val(command), path(abricate_result_file)
}