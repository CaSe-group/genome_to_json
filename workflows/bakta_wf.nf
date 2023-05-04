include { bakta } from './process/bakta.nf'
include { bakta_database } from './process/bakta.nf'

workflow bakta_wf {
    take:
        fasta_input // tuple val(name), path(fasta-file)
    main:                          
        if ( params.bakta ) { 
            if (params.bakta_db) { database_bakta = file(params.bakta_db) }
            else { database_bakta = bakta_database() }
                
            bakta(fasta_input,database_bakta)
            bakta_output_ch = bakta.out.bakta_file_ch
            bakta_report_ch = bakta.out.bakta_report_ch
        }
        else {
            bakta_output_ch = Channel.empty()
            bakta_report_ch = Channel.empty()
        }
    emit:
        to_json = bakta_output_ch // tuple val(name), file(bakta_result_file), path(bakta_info_file)
        to_report = bakta_report_ch // tuple val(name), val(version), val(db_version), val(command), file(bakta_result_file)
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