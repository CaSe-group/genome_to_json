process json_report {
        publishDir "${params.output}/${name}/${params.jsondir}/", mode: 'copy'
        label 'python3'
    input:
        tuple val(name), path(abricate_result), val(abricate_db_version), path(prokka_result), path(sourmash_result)
    output:
	    tuple val(name), path("*.json")
    script:
    if ( !params.abricate_off) { abricate_input = "${abricate_result},${abricate_db_version}" }
    else { abricate_input = "false" }

    if ( !params.prokka_off) { prokka_input = "${prokka_result}" }
    else { prokka_input = "false" }

    if ( !params.sourmash_off) { sourmash_input = "${sourmash_result}" }
    else { sourmash_input = "false" }

    """
    json_parser.py -i ${name} \
        -a ${abricate_input} \
        -n ${params.new_entry} \
        -p ${prokka_input} \
        -s ${sourmash_input}
    """
}