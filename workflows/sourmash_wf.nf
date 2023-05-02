include {sourmash_db_download} from './process/sourmash.nf'
include {sourmash_classification; sourmash_signatures; sourmash_metagenome} from './process/sourmash.nf'

workflow sourmash_wf{
	take:
		fasta_input // tuple val(name), path(fasta-file)
	main:
		if ( params.sourmash ) { 
			sourmash_db_download()
			sourmash_signatures(fasta_input)
			sourmash_metagenome(fasta_input, sourmash_db_download.out)
			sourmash_output_ch = sourmash_classification(sourmash_signatures.out, sourmash_db_download.out)
			sourmash_report_ch = sourmash_classification.out.map{it -> tuple(it[0],it[1])}.join(sourmash_metagenome.out)
		}
        else { 
			sourmash_output_ch = Channel.empty()
			sourmash_report_ch = Channel.empty()
        }
	emit:
		to_json = sourmash_output_ch // tuple val(name), path(sourmash_classification_result_file), path(sourmash_info_file)
		to_report = sourmash_report_ch // tuple val(name), path(sourmash_classification_result_file), path(sourmash_metagenome_result_file)
}
