process json_report {
        publishDir "${params.output}/${name}/${params.jsondir}/", mode: 'copy'
        label 'python3'
    input:
        tuple val(name), path(abricate_result), path(prokka_result), path(sourmash_result)
    output:
	    tuple val(name), path("*.json")
    script:
    if ( !params.abricate_off) { abricate_option = "${abricate_result}" }
    else { abricate_option = 'False' }

    if ( !params.prokka_off) { prokka_option = "${prokka_result}" }
    else { prokka_option = 'False' }

    if ( !params.sourmash_off) { sourmash_option = "${sourmash_result}" }
    else { sourmash_option = 'False' }

    """
    json_parser.py -i ${name} \
        -a ${abricate_option} \
        -p ${prokka_option} \
        -s ${sourmash_option}
    """
}