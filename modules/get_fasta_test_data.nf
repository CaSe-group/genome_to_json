
process get_fasta {
  	container = 'nanozoo/template:3.8--d089809'
	output:
	path("*.fasta") 
	script:
	"""
    wget https://osf.io/dm93b/download -O GCA_000534275.1.fasta
	"""
}