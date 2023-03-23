include{ pgap } from './process/pgap.nf'
include{ pgap_database } from './process/pgap.nf'

workflow eggnog_wf {
    take:
        fasta //tuple val(NAME), path({NAME}.fasta)
        species
    main:  
if (params.pgap_db) { pgap_db = file(params.pgap_db) }
        else { pgap_db = pgap_database(params.pgap_v) }

    pgap(combined_fasta_ch, species, pgap_db)

    emit:
        pgap_output = pgap_output_ch 
}