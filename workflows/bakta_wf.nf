include { bakta } from './process/bakta.nf'
include { bakta_database } from './process/bakta_database.nf'

workflow bakta_wf {
    take:   fasta_input
    main:   
            if (params.bakta_db) { database_bakta = file(params.bakta_db) }
            else if ( !params.bakta_db ) { database_bakta = bakta_database() }
                       
            if (!params.bakta_off) { bakta(fasta_input,database_bakta) ; bakta_rep_ch = bakta.out.bakta_report_ch ; bakta_json_ch = bakta.out.bakta_json_ch }
            else { bakta_output_ch = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'bakta_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
                                    .combine(Channel.from('#no_data#')) //create & add dummy-val to the tuple
                   bakta_report = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'bakta_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
                                    .combine(Channel.from('#no_data#')) //create & add dummy-val to the tuple
        }

    emit:
        to_json = bakta_json_ch 
        to_report = bakta_rep_ch
}

/*
List available DB versions:
$ bakta_db list
...
Download the most recent compatible database version we recommend to use the internal database download & setup tool:
$ bakta_db download --output <output-path>
Of course, the database can also be downloaded manually:
$ wget https://zenodo.org/record/5215743/files/db.tar.gz
$ tar -xzf db.tar.gz
$ rm db.tar.gz
$ amrfinder_update --force_update --database db/amrfinderplus-db/
In this case, please also download the AMRFinderPlus database as indicated above.
Update an existing database:
$ bakta_db update --db <existing-db-path> [--tmp-dir <tmp-directory>]
The database path can be provided either via parameter (--db) or environment variable (BAKTA_DB):
$ bakta --db <db-path> genome.fasta
$ export BAKTA_DB=<db-path>
$ bakta genome.fasta
*/