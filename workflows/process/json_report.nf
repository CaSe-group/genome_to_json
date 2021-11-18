process json_report {
        publishDir "${params.output}/${name}/", mode: 'copy'
        publishDir "${params.output}/${params.jsondir}/", mode: 'copy'
        label 'python3'
    
    input:
        tuple val(name), path(abricate_result), val(abricate_db_version), path(bakta_result), val(bakta_version), path(prokka_result), val(prokka_version), path(sourmash_result), val(sourmash_version)
    output:
	    tuple val(name), path("*.json")
    script:
        if ( !params.abricate_off) { abricate_input = "${abricate_result},${abricate_db_version}" }
        else { abricate_input = "false" }

        if ( !params.bakta_off) { bakta_input = "${bakta_result},${bakta_version}" }
        else { bakta_input = "false" }

        if ( !params.prokka_off) { prokka_input = "${prokka_result},${prokka_version}"}
        else { prokka_input = "false" }

        if ( !params.sourmash_off) { sourmash_input = "${sourmash_result},${sourmash_version}" }
        else { sourmash_input = "false" }

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