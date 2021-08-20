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
	echo ">A\nATGCC" >A.fasta
	echo ">B\nTTGGC" >B.fasta
	"""
}