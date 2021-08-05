# Genome to mongo DB json
* CaSe-group workflow to generate mongo DB jsons out of microbial genomes
* wrapped in a nextflow workflow to quickly gather the important features and collect them in a json file


## ToDos
* [ ] taxonomic determination [sourmash GTDB]
* [ ] plasmid [yes/no]
* [x] resistance determination (e.g. abricate)
* [x] annotation (e.g. prokka  - or one of the newer ones)
* [ ] contamination[yes/no] yes -> with what
* [x] flexible multifasta input
