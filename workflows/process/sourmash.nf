process sourmash_signatures {
    label 'sourmash'   
    // publishDir "${params.output}/sourmash_signatures", mode:'copy', pattern: "*.sig"
    
    input:
        tuple val(name), path(reads)
    output:
        tuple val(name), path("*.sig")
    script:
        """
        sourmash sketch dna -p scaled=1000,k=31 --name-from-first ${reads}
        """
}

process sourmash_classification {
    label 'sourmash'
    publishDir "${params.output}/${name}/${params.sourmashdir}", mode: 'copy', pattern: "${name}_taxonomy.tsv"
    
    input:
        tuple val(name), path(signatures)
        path(sourmash_db)
    output: 
        tuple val(name), path("${name}_taxonomy.tsv")
    script:
        """
        sourmash lca classify \
            --db ${sourmash_db} \
            --query ${signatures} \
            > ${name}_taxonomy.tsv
        """  
}

