include { json_report } from './process/json_report' 

workflow create_json_entries_wf {
    take: 
        abricate
        proka
        sourmash
    main:
        merged_ch = abricate.join(proka.map { it -> tuple(it[0], it[1])}.join(sourmash))

        json_report(merged_ch)      

} 
