process busco {
    label 'busco'
    publishDir "${params.output}/${name}/${params.buscodir}", mode: 'copy', pattern: "*"
    
    input:
        tuple val(name), path(fasta)
        path(busco_db_dir)
    output: 
        tuple val(name), path("${name}_busco_results"), path("busco_version.txt")
    script:
        """
        DATASET_BASENAME=\$(echo "${params.busco_db}" | cut -f 1 -d '.')

        busco --in ${fasta} \
            --lineage_dataset \${DATASET_BASENAME} \
            --offline \
            --download_path ${busco_db_dir}/ \
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

process busco_db_download {
    label 'ubuntu'
    storeDir "${params.databases}/busco"
    
    output:
        path("busco_downloads")
    script:
        """
        mkdir -p busco_downloads/lineages
        wget --no-check-certificate https://busco-data.ezlab.org/v5/data/file_versions.tsv -P busco_downloads/
        wget --no-check-certificate "https://busco-data.ezlab.org/v5/data/lineages/${params.busco_db}" -P busco_downloads/lineages/
        tar -xzf "busco_downloads/lineages/${params.busco_db}"
        DATASET_BASENAME=\$(echo "${params.busco_db}" | cut -f 1 -d '.')
        mv busco_downloads/lineages/${params.busco_db} busco_downloads/lineages/\${DATASET_BASENAME}
        """  
    stub:
        """
        touch busco_downloads
        """
}