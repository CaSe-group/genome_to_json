include { collect_fasta } from './process/collect_fasta.nf'

workflow collect_fasta_wf {
    take: 
        fasta_input_raw_ch 
    main:
        fasta_input_raw_ch = collect_fasta(fasta_input_raw_ch).flatten()
    emit:
        fasta_input_ch
}