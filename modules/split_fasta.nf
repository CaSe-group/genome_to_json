process split_fasta {
	label 'python3'
	input:
		path(fasta_input_raw)
	output:
		path("split_fasta/*.fasta")
	script:
	"""
	mkdir -p split_fasta
	split_fasta.py ${fasta_input_raw}
	"""
	stub:
	"""
	mkdir -p split_fasta
	echo ">A\\nATGCC" > split_fasta/A.fasta
	echo ">B\\nTTGGC" > split_fasta/B.fasta
	"""
}