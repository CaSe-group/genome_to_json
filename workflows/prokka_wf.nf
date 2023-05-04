include { prokka } from './process/prokka.nf' 

workflow prokka_wf {
    take: 
        fasta_input // tuple val(name), path(fasta-file)
    main:
        if ( params.prokka ) {
            prokka(fasta_input)
            prokka_output_ch = prokka.out.prokka_file_ch
            prokka_report_ch = prokka.out.prokka_report_ch
        }
        else { 
            prokka_output_ch = Channel.empty()
            prokka_report_ch = Channel.empty()
        }
    emit:
        to_json = prokka_output_ch // tuple val(name), path(prokka_result_file), path(prokka_info_file)
        to_report = prokka_report_ch // tuple val(name), val(version), val(db_version), val(command), path(prokka_result_file)
}