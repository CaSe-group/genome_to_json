include { prokka } from './process/prokka.nf' 

workflow annotation_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.prokka_off) { prokka(fasta_input) ; prokka_output_ch = prokka.out.prokka_tsv_ch }
        else { prokka_output_ch = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'prokka_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
                                    .combine(Channel.from('#no_data#')) //create & add dummy-val to the tuple
        }
    emit:
        prokka_output_ch //tuple val(fasta_basename) path(prokka_file) val(prokka_version)
}