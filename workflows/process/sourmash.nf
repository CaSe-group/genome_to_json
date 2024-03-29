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
    publishDir "${params.output}/${name}/${params.sourmashdir}", mode: 'copy', pattern: "${name}_sourmash_taxonomy.csv"

    input:
        tuple val(name), path(signatures)
        path(sourmash_db)
    output: 
        tuple val(name), path("${name}_sourmash_taxonomy.csv"), path("sourmash_tool_info.txt"), emit: sourmash_file_ch
        tuple val(name), env(SOURMASH_VERSION), env(SOURMASH_DB_VERSION), env(COMMAND_TEXT), path("${name}_sourmash_taxonomy.csv"), emit: sourmash_report_ch
    script:
        """
        sourmash lca classify \
            --db ${sourmash_db} \
            --query ${signatures} \
            > ${name}_sourmash_taxonomy.csv

        SOURMASH_VERSION=\$(sourmash --version | cut -f 2 -d ' ')
        echo "Sourmash-Version: \${SOURMASH_VERSION}" >> sourmash_tool_info.txt

        SOURMASH_DB_VERSION=\$(echo "${sourmash_db}")
        echo "DB-Version(s): \${SOURMASH_DB_VERSION}" >> sourmash_tool_info.txt

        COMMAND_TEXT=\$(echo "sourmash lca classify --db ${sourmash_db} --query ${signatures} > ${name}_sourmash_taxonomy.csv")
        echo "Used Command: \${COMMAND_TEXT}" >> sourmash_tool_info.txt
        """  
    stub:
        """
        touch ${name}_sourmash_taxonomy.csv \
            sourmash_tool_info.txt
        """
}

process sourmash_db_download {
    label 'ubuntu'
    storeDir "${params.databases}/sourmash"

    output:
        path("*.json.gz")
    script:
        """
        wget --no-check-certificate -O gtdb-rs202.genomic.k31.lca.json.gz https://osf.io/9xdg2/download 
        """
    stub:
        """
        touch gtdb-rs202.genomic.k31.lca.json.gz
        """
}

process sourmash_metagenome {
    label 'sourmash'
    publishDir "${params.output}/${name}/${params.sourmashdir}", mode: 'copy', pattern: "${name}_sourmash_composition.csv"

    input:
        tuple val(name), path(reads)
        path(sourmash_db)
    output:
        tuple val(name), path("*_sourmash_composition.csv")
    script:
        """    
        sourmash sketch dna -p scaled=1000,k=31 ${reads} -o ${name}_sourmash.sig
        sourmash gather ${name}_sourmash.sig ${sourmash_db} --ignore-abundance -o ${name}_sourmash_composition.csv
        """
    stub:
        """
        touch ${name}_sourmash_composition.csv
        """
}
