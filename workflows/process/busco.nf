process busco {
    label 'busco'
    publishDir "${params.output}/${name}/${params.buscodir}", mode: 'copy', pattern: "*"
    
    input:
        tuple val(name), path(fasta)
    output: 
        tuple val(name), path("${name}_busco_results"), path("busco_version.txt")
    script:
        """
        busco --in ${fasta} \
            --lineage_dataset bacteria_odb10 \
            --out ./${name}_busco_results \
            --mode genome

        busco --version | cut -f 2 -d ' ' >> busco_version.txt
        """  
    stub:
        """
        touch ${name}_busco.tsv
        BUSCO_VERSION=stub
        """
}