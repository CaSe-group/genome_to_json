process split_fasta {
	label 'python3'
	publishDir "${params.output}/Genomes", mode: 'copy'
	input:
		path(fasta_input_raw)
	output:
		path("split_fasta/*.fasta")
	script:
	"""
	mkdir -p split_fasta
	split_fasta.py ${fasta_input_raw}
	"""
}