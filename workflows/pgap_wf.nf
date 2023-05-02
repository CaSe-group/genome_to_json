include{ pgap} from './process/pgap.nf'
include{ pgap_database } from './process/pgap.nf'

workflow pgap_wf {
    take:
        fasta // tuple val(name), path(fasta-file)
        species
    main:  
    if ( params.pgap ) { 
        if (params.pgap_db) { pgap_db = file(params.pgap_db) }
            else { pgap_db = pgap_database(params.pgap_v) }
        pgap(fasta, species, pgap_db)
        pgap_output_ch = Channel.empty()
        pgap_report_ch = Channel.empty()
    }
    else {
        pgap_output_ch = Channel.empty()
        pgap_report_ch = Channel.empty()
    }   


    emit:
        to_json = pgap_output_ch 
        to_report = pgap_report_ch
}