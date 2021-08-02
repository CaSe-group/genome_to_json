// include { sourmash } from './process/sourmash.nf' 

workflow taxonomic_determination_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.sourmash_off) { sourmash_output_ch = sourmash(fasta_input) }
        else { sourmash_output_ch = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'sourmash_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
        }
    emit:
        sourmash_output_ch //tuple val(fasta_basename) path(sourmash_file)
}