process json_report {
        publishDir "${params.output}/${params.jsondir}/", mode: 'copy'
        label 'python3'
    input:
        tuple val(name), path(abricate_result), path(proka_result), path(sourmash_result)
    output:
	    tuple val(name), path("*.json")
    script:
    """
    json_parser.py -i ${name} \
        -a ${abricate_result} \
        -p ${proka_result} \
        -s ${sourmash_result} \
    """
}