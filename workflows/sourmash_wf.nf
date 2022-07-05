include {download_db} from './process/download_db.nf'
include {sourmash_classification; sourmash_signatures; sourmash_metagenome} from './process/sourmash'

workflow sourmash_wf{
	take:
		fasta_input //tuple val(fasta_basename) path(fasta_file)
	main:
		if (!params.sourmash_off) { 
			download_db()
			sourmash_signatures(fasta_input)
			sourmash_metagenome(fasta_input, download_db.out)
			sourmash_output_ch = sourmash_classification(sourmash_signatures.out, download_db.out)
			sourmash_report_ch = sourmash_classification.out.map{it -> tuple(it[0],it[1])}.join(sourmash_metagenome.out)
		}
        else { 
			sourmash_output_ch = Channel.empty()
			sourmash_report_ch = Channel.empty()
        }
	emit:
		to_json = sourmash_output_ch
		to_report = sourmash_report_ch
}
