include { abricate; abricate_combiner } from './process/abricate.nf'

workflow abricate_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.abricate_off) {
            if (!params.deep_json) {
                abricate_db = ['ncbi', 'card', 'vfdb', 'ecoh', 'argannot', 'plasmidfinder', 'resfinder'] //define ArrayList with ABRicate-databases to run
                abricate(fasta_input, abricate_db)  //start process abricate with according variables
                
                abricate_combiner(abricate.out.abricate_ncbi_output_ch)    //assign main-output of abricate-process to channel
            }
            else {
                abricate_db = ['plasmidfinder', 'resfinder']
                abricate(fasta_input, abricate_db)  //start process abricate with according variables
                
                abricate_output_ch_raw = abricate.out.abricate_deep_json_output_ch.groupTuple()      //assign main-output of abricate-process to channel
                abricate_combiner(abricate_output_ch_raw)
            }
            abricate_output_ch = abricate_combiner.out.abricate_combiner_file_output_ch
            abricate_report_ch = abricate_combiner.out.abricate_combiner_report_output_ch
            //abricate_output_ch.view()
            //abricate_report_ch.view()
        }
        else {
            abricate_output_ch = Channel.empty()
            abricate_report_ch = Channel.empty()
        }
    emit:
        to_json = abricate_output_ch //tuple val(fasta_basename) path(abricate_db_version_file) path(abricate_file) 
        to_report =  abricate_report_ch //tuple val(fasta_basename) path(abricate_file)
}