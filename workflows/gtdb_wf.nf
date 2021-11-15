include { gtdbtk } from './process/gtdbtk.nf'
include { gtdb_db_download } from './process/gtdb_db_download.nf' 

workflow gtdb_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.gtdb_off) {
            gtdb_db_download()  //download gtdb-database if not already stored
            gtdbtk(fasta_input, gtdb_db_download.out)   //start process gtdbtk with according variables
            gtdbtk_output_ch = gtdbtk.out   //assign main-output of gtdb-process to channel
        }
        else {
            gtdbtk_output_ch = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'gtdb_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
        }
    emit:
        to_json = gtdbtk_output_ch  //tuple val(fasta_basename) path(gtdb_result_dir)
        to_report = gtdbtk_output_ch    //tuple val(fasta_basename) path(gtdb_result_dir)
}