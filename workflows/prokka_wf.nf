include { prokka } from './process/prokka.nf' 

workflow prokka_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
        if (!params.prokka_off) { 
            prokka(fasta_input)
            prokka_json_ch = prokka.out.prokka_tsv_ch
            prokka_report_ch = prokka.out.prokka_report_ch
        }
        else { prokka_json_ch = Channel.empty()
        //fasta_input
                                    //.map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    //.combine(Channel.from('#no_data#')
                                    //.collectFile(name: 'prokka_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
                                    //.combine(Channel.from('#no_data#')) //create & add dummy-val to the tuple
                prokka_report_ch = Channel.empty()
                //fasta_input
                                    //.map{ it -> tuple(it[0]) } //take basename from fasta_input-tuple
                                    //.combine(Channel.from('#no_data#')
                                    //.collectFile(name: 'prokka_dummy.txt', newLine: true)) //create & add dummy-file to the tuple
        }
    emit:
        to_json = prokka_json_ch //tuple val(fasta_basename) path(fasta_basename_prokka/fasta_basename_prokka.tsv) val(prokka_version)
        to_report = prokka_report_ch //tuple val(fasta_basename), path(fasta_basename_prokka/fasta_basename_prokka.gff)
}