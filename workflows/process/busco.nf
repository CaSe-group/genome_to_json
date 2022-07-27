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
            --out ${name}_busco_results \
            --mode genome

        generate_plot.py -wd ./${name}_busco_results

        busco --version | cut -f 2 -d ' ' >> busco_version.txt
        """  
    stub:
        """
        touch ${name}_busco.tsv
        echo "stub" >> busco_version.txt
        """
}

process busco_db_download {
    label 'ubuntu'
    storeDir "${params.databases}/busco"
    
    output:
        tuple path("busco_downloads/file_versions.tsv"), path("busco_downloads/placement_files"), path("busco_downloads/lineages/${busco_db_basename}"), emit: busco_db_storage_ch
        path("busco_downloads"), emit: busco_db_ch
    script:
        busco_db_basename = params.busco_db.split("\\.")[0] //set new nextflow-variable to specify used database for output-pattern
        """
        mkdir -p busco_downloads/lineages busco_downloads/placement_files
        wget --no-check-certificate https://busco-data.ezlab.org/v5/data/file_versions.tsv -P busco_downloads/
        wget --no-check-certificate "https://busco-data.ezlab.org/v5/data/lineages/${params.busco_db}"
        wget --no-check-certificate --no-parent --recursive https://busco-data.ezlab.org/v5/data/placement_files/
        for FILE in busco-data.ezlab.org/v5/data/placement_files/*.tar.gz; do tar -xzf \${FILE} -C busco_downloads/placement_files/; done
        rm -rf ./busco-data.ezlab.org/
        tar --no-same-owner -xzf ${params.busco_db} -C busco_downloads/lineages/
        """  
    stub:
        """
        mkdir -p busco_downloads/lineages busco_downloads/placement_files
        touch busco_downloads/file_versions.tsv
        touch busco_downloads/lineages/bacteria_odb10
        """
}