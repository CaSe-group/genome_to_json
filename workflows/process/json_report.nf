process json_report {
        publishDir "${params.output}/${name}/", mode: 'copy'
        publishDir "${params.output}/${params.jsondir}/", mode: 'copy'
        label 'python3'
        errorStrategy 'ignore'
    
    input:
        tuple val(name), file(files)
    output:
	    tuple val(name), path("*.json")
    script:
    
        if ( !params.abricate_off) { abricate_input = "*abricate_ncbi.tsv,*abricate_ncbi_version.txt" }
        else { abricate_input = "false" }

        if ( !params.bakta_off) { bakta_input = "*_bakta.tsv,*bakta_version.txt" }
        else { bakta_input = "false" }

        if ( !params.prokka_off) { prokka_input = "*_prokka.tsv,*prokka_version.txt"}
        else { prokka_input = "false" }

        if ( !params.sourmash_off) { sourmash_input = "*_sourmash_taxonomy.csv,*sourmash_version.txt" }
        else { sourmash_input = "false" }
     
        """
        json_parser.py -i ${name} \
            -a ${abricate_input} \
            -b ${bakta_input} \
            -n ${params.new_entry} \
            -p ${prokka_input} \
            -s ${sourmash_input}
        """
    stub:
        """
        touch "${name}"_report.json
        """
}