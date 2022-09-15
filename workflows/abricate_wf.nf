include { abricate } from './process/abricate.nf'

workflow abricate_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.abricate_off) {
            abricate_db = ['ncbi', 'card', 'vfdb', 'ecoh', 'argannot', 'plasmidfinder', 'resfinder']
            abricate(fasta_input, abricate_db)  //start process abricate with according variables
            abricate_output_ch = abricate.out.abricate_output_ch    //assign main-output of abricate-process to channel
            abricate_report_ch = abricate_output_ch.map{ it -> tuple (it[0], it[1])}
        }
        else {
            abricate_output_ch = Channel.empty()
            abricate_report_ch = Channel.empty()
        }
    emit:
        to_json = abricate_output_ch //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version)
        to_report =  abricate_report_ch//tuple val(fasta_basename) path(abricate_file)
}