include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate    // tuple val(name), path(abricate_info_file), path(abricate_result_file)
        bakta      // tuple val(name), file(bakta_result_file), path(bakta_info_file)
        busco       // tuple val(name), path(busco_info_file), path(busco_result-file)
        prokka      // tuple val(name), path(prokka_result_file), path(prokka_info_file)
        sourmash    // tuple val(name), path(sourmash_classification_result_file), path(sourmash_info_file)
    main:
        merged_ch = abricate.mix(bakta, busco, prokka, sourmash).groupTuple(by: 0).map{ it -> tuple (it[0], tuple (it[1],it[2]).flatten()) }
        // to use "groupTuple()" all channels must have the same nr of elements > otherwise results in error: "Cannot invoke method add() on null object"
        //merged_ch.view() //tuple val(fasta-basename), path(analysis_result-files_1)
        json_report(merged_ch)
}