include { prokka } from './process/prokka.nf' 

workflow prokka_wf {
    take: 
        fasta_input //tuple val(fasta-basename) path(fasta-file)
    main:
        if (!params.prokka_off) { 
            prokka(fasta_input)
            prokka_json_ch = prokka.out.prokka_tsv_ch
            prokka_report_ch = prokka.out.prokka_report_ch
        }
        else { prokka_json_ch = Channel.empty()
            prokka_report_ch = Channel.empty()
        }
    emit:
        to_json = prokka_json_ch //tuple val(fasta-basename) path(fasta-basename_prokka.tsv) val(prokka_version.txt)
        to_report = prokka_report_ch //tuple val(fasta-basename), path(fasta-basename_prokka.gff)
}