include { abricate } from './process/abricate.nf'

workflow resistance_determination_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.abricate_off) {
            abricate_db = ['ncbi', 'card', 'vfdb', 'ecoh', 'argannot', 'plasmidfinder', 'resfinder']
            abricate(fasta_input, abricate_db)  //start process abricate with according variables
            abricate_output_ch = abricate.out.abricate_output_ch    //assign main-output of abricate-process to channel
        }
        else { abricate_output_ch = fasta_input
                                    .map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    .combine(Channel.from('#no_data#')
                                    .collectFile(name: 'abricate_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
                                    .combine(Channel.from('#no_data#')) //create & add dummy-val to the tuple
        }
    emit:
        to_json = abricate_output_ch //tuple val(fasta_basename) path(abricate_file) val(abricate_db_version)
        to_report = abricate_output_ch.map{ it -> tuple (it[0], it[1])} //tuple val(fasta_basename) path(abricate_file)
}