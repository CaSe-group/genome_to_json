include {download_db} from './process/download_db.nf'
include {sourmash_classification; sourmash_signatures} from './process/sourmash'

workflow taxonomic_classification_wf{
	take:
		fasta_input //tuple val(fasta_basename) path(fasta_file)
	main:
		if (!params.sourmash_off) { 
			download_db()
			sourmash_signatures(fasta_input)
			sourmash_output_ch = sourmash_classification(sourmash_signatures.out, download_db.out)
		}
        else { sourmash_output_ch = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'sourmash_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
        }
	emit:
		sourmash_output_ch //tuple val(fasta_basename) path(sourmash_file)
}