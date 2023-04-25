# Bacventure
## Bacterial Genome Analyser
* CaSe-group workflow to analyze microbial genomes creating a detailed report & json
* wrapped in a nextflow workflow to quickly gather the important features and collect the different tool-outputs accordingly


## Features
* taxonomic determination [sourmash]
* contamination check [sourmash]
* completeness check [busco]
* resistance determination [ABRicate]
* gene annotation [bakta; eggnog; pgap; prokka]

also for mutlifasta-input & different packing-formats [.gz; .xz].

## ToDos
* [ ] plasmid [yes/no]
