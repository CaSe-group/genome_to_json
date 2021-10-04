# Genome to mongo DB json
* CaSe-group workflow to generate mongo DB jsons out of microbial genomes
* wrapped in a nextflow workflow to quickly gather the important features and collect them in a json file


## ToDos
* [X] taxonomic determination [sourmash GTDB]
* [ ] plasmid [yes/no]
* [x] resistance determination (e.g. abricate)
* [x] annotation (e.g. prokka  - or one of the newer ones)
* [x] contamination[yes/no] yes -> with what
* [x] flexible multifasta input
