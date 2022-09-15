include { abricate } from './process/abricate.nf'

workflow abricate_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.abricate_off) {
            abricate_db = ['ncbi', 'card', 'vfdb', 'ecoh', 'argannot', 'plasmidfinder', 'resfinder']
            abricate(fasta_input, abricate_db)  //start process abricate with according variables
            if (!params.deep_json) {
                abricate_output_ch = abricate.out.abricate_ncbi_output_ch    //assign main-output of abricate-process to channel
                abricate_report_ch = abricate_output_ch.map{ it -> tuple (it[0], it[2])}
            }
            else {
                abricate_output_ch_raw = abricate.out.abricate_resfinder_output_ch.join(abricate.out.abricate_plasmidfinder_output_ch)      //assign main-output of abricate-process to channel
                //abricate_output_ch_raw_sorted = abricate_output_ch_raw.map{ it -> it.findAll{it =~ ".txt"}}.flatten().collectFile() { item -> [ "abricate_db_version.txt", item ] }.view()
                //abricate_output_ch_raw_sorted = abricate_output_ch_raw.map{ it -> it[0], it.findAll{it =~ ".txt"}.flatten().collectFile() { item -> [ "abricate_db_version.txt", item ] }, it.findAll{it =~ ".tsv"}.flatten()}.view()
                abricate_output_ch_id = abricate_output_ch_raw.map{ it -> it[0]}//.view()
                abricate_output_ch_version_files = abricate_output_ch_raw.map{ it -> it.findAll{it =~ ".txt"}}.flatten().collectFile() { item -> [ "abricate_db_version.txt", item ] }//.view()
                abricate_output_ch_result_files = abricate_output_ch_raw.map{ it -> it.findAll{it =~ ".tsv"}}.flatten().collectFile(keepHeader: true) { item -> [ "abricate_db_complete.tsv", item ] }//.view()
                abricate_output_ch = abricate_output_ch_id.merge(abricate_output_ch_version_files).merge(abricate_output_ch_result_files, remainder: true)
                abricate_report_ch = abricate_output_ch.map{ it -> tuple (it[0], it[2])}
            }
            abricate_output_ch.view()
        }
        else {
            abricate_output_ch = Channel.empty()
            abricate_report_ch = Channel.empty()
        }
    emit:
        to_json = abricate_output_ch //tuple val(fasta_basename) path(abricate_db_version_file) path(abricate_file) 
        to_report =  abricate_report_ch //tuple val(fasta_basename) path(abricate_file)
}