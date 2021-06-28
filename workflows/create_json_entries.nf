include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate
        prokka
        sourmash
    main:
        merged_ch = abricate.join(prokka.map { it -> tuple(it[0], it[1])}.join(sourmash))

        json_report(merged_ch)      

} 
