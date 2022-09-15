include { prokka } from './process/prokka.nf' 

workflow prokka_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.prokka_off) {
            prokka(fasta_input)
            prokka_output_ch = prokka.out.prokka_tsv_ch
            prokka_report_ch = prokka.out.prokka_report_ch
        }
        else { 
            prokka_output_ch = Channel.empty()
            prokka_report_ch = Channel.empty()
        }
    emit:
        to_json = prokka_output_ch //tuple val(fasta_basename) path(prokka_file) val(prokka_version)
        to_report = prokka_report_ch
}