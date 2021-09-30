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
    stub:
        """
        touch signature.sig
        """
}

process sourmash_classification {
    label 'sourmash'
    publishDir "${params.output}/${name}/${params.sourmashdir}", mode: 'copy', pattern: "${name}_taxonomy.tsv"
    
    input:
        tuple val(name), path(signatures)
        path(sourmash_db)
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

process sourmash_metagenome {
    label 'sourmash'
    publishDir "${params.output}/${name}/${params.sourmashdir}", mode: 'copy', pattern: "${name}_composition.csv"
    
    input:
        tuple val(name), path(reads)
        path(sourmash_db)
    output:
        tuple val(name), path("*_composition.csv")
    script:
        """    
        sourmash sketch dna -p scaled=10000,k=31 ${reads} -o ${name}.sig
        sourmash gather ${name}.sig ${sourmash_db} --ignore-abundance -o ${name}_composition.csv
        """
}
