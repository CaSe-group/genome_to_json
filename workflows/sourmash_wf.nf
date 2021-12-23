include {download_db} from './process/download_db.nf'
include {sourmash_classification; sourmash_signatures; sourmash_metagenome} from './process/sourmash'

workflow sourmash_wf{
	take:
		fasta_input //tuple val(fasta_basename) path(fasta_file)
	main:
		if (!params.sourmash_off) { 
			download_db()
			sourmash_signatures(fasta_input)
			sourmash_taxonomy_ch = sourmash_classification(sourmash_signatures.out, download_db.out)
			sourmash_metagenome_ch = sourmash_metagenome(fasta_input, download_db.out)
		}
        else { sourmash_taxonomy_ch = Channel.empty()
                sourmash_metagenome_ch = Channel.empty()
        }
    emit:
        to_json = sourmash_taxonomy_ch //tuple val(fasta_basename), path(fasta_basename_taxonomy.tsv), env(sourmash_version)
        to_report = sourmash_taxonomy_ch.map{it -> tuple(it[0],it[1])}.join(sourmash_metagenome_ch) //tuple val(fasta_basename), path(fasta_basename_taxonomy.tsv), path(fasta_basename_composition.csv)
}