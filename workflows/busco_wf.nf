include { busco } from './process/busco.nf'

workflow busco_wf {
    take:
        fasta //tuple val(NAME), path({NAME}.fasta)
    main:   
        if (!params.busco_off) { 
            busco(fasta)
        }
        else {
            busco_output_ch = Channel.empty()
            busco_report = Channel.empty()
        }
    //emit:
        //to_json = busco_json_ch 
        //to_report = busco_rep_ch
}