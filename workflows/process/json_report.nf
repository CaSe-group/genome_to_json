process json_report {
        label 'python3'
        publishDir "${params.output}/${name}/", mode: 'copy'
        publishDir "${params.output}/${params.jsondir}/", mode: 'copy'
    input:
        tuple val(name), path(abricate_result), val(abricate_db_version), path(bakta_result), val(bakta_version), path(sourmash_result), val(sourmash_version), path(gtdb_result_dir)
    output:
	    tuple val(name), path("*.json")
    script:
        if ( !params.abricate_off ) { abricate_input = "${abricate_result},${abricate_db_version}" }
        else { abricate_input = "false" }

        if ( !params.bakta_off ) { bakta_input = "${bakta_result},${bakta_version}" }
        else { bakta_input = "false" }

        if ( !params.sourmash_off ) { sourmash_input = "${sourmash_result},${sourmash_version}" }
        else { sourmash_input = "false" }

        if ( !params.gtdb_off ) { gtdb_input = "${gtdb_result_dir}" }
        else { gtdb_input = "false" }
        """
        json_parser.py -i ${name} \
            -a ${abricate_input} \
            -n ${params.new_entry} \
            -p ${bakta_input} \
            -s ${sourmash_input}
        """
    stub:
        """
        touch "${name}"_report.json
        """
}