process get_fasta {
  	label 'python3'
	output:
	path("*.fasta") 
	script:
	"""
    wget  --no-check-certificate https://osf.io/dm93b/download -O GCA_000534275.1.fasta
	"""
}