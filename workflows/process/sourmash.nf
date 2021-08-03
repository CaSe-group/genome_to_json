process sourmash_signatures {
label 'sourmash'   
//  publishDir "${params.output}/sourmash_signatures", mode:'copy', pattern: "*.sig"
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
    publishDir "${params.output}/${name}/3.sourmash", mode: 'copy', pattern: "${name}_taxonomy.tsv"
    input:
        tuple val(name), path(signatures)
        file query
    output: 
        tuple val(name), path("${name}_taxonomy.tsv")
    script:
    """
    sourmash lca classify \
        --db genbank-k31.lca.json.gz \
        --query ${signatures} \
        > ${name}_taxonomy.tsv
    """  
}

