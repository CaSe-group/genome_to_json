process busco {
    label 'busco'
    publishDir "${params.output}/${name}/${params.buscodir}", mode: 'copy', pattern: "*"
    
    input:
        tuple val(name), path(fasta)
    output: 
        tuple val(name), path("${name}_busco_results"), env(BUSCO_VERSION)
    script:
        """
        busco --in ${fasta} \
            --lineage_dataset bacteria_odb10 \
            --out ./${name}_busco_results \
            --mode genome

        BUSCO_VERSION=\$(busco --version | cut -f 2 -d ' ') 
        """  
    stub:
        """
        touch ${name}_busco.tsv
        BUSCO_VERSION=stub
        """
}