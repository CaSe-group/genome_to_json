process busco {
    label 'busco'
    publishDir "${params.output}/${name}/${params.buscodir}", mode: 'copy', pattern: "*"
    
    input:
        tuple val(name), path(fasta), path(sourmash_result)
    output: 
        tuple val(name), path("${name}_taxonomy.tsv"), env(SOURMASH_VERSION)
    script:
        """
        sourmash lca classify \
            --db ${sourmash_db} \
            --query ${signatures} \
            > ${name}_taxonomy.tsv

        SOURMASH_VERSION=\$(sourmash --version | cut -f 2 -d ' ') 
        """  
    stub:
        """
        touch ${name}_taxonomy.tsv
        SOURMASH_VERSION=stub
        """
}