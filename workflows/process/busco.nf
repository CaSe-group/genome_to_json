process busco {
    label 'busco'
    publishDir "${params.output}/${name}/${params.buscodir}", mode: 'copy', pattern: "busco_tool_info.txt"
    publishDir "${params.output}/${name}/${params.buscodir}", mode: 'copy', pattern: "*_busco_results"
    
    input:
        tuple val(name), path(fasta)
        path(busco_db_dir)
    output: 
        tuple val(name), path("busco_tool_info_for_report.txt"), path("${name}_busco_results.tsv"),  emit: busco_file_output_ch
        tuple val(name), env(BUSCO_VERSION), env(BUSCO_DB_VERSION), env(COMMAND_TEXT), env(PLOT_PERCENTAGE_VALUES), env(PLOT_ABSOLUTE_VALUES), path("${name}_busco_results.tsv"), emit: busco_report_output_ch
        tuple val(name), path("busco_tool_info.txt"), path("${name}_busco_results"), emit: busco_files_ch //secondary output-channel to activate publishDir
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
        
        tail -n +3 ${name}_busco_results/run_\${DATASET_BASENAME}/full_table.tsv | sed "s/# Busco id/Busco_id/" > ./${name}_busco_results.tsv
        
        PLOT_PERCENTAGE_VALUES=\$(tail -n +40 ${name}_busco_results/busco_figure.R | head -n 1 | cut -f 3- -d ' ')
        PLOT_ABSOLUTE_VALUES=\$(tail -n +41 ${name}_busco_results/busco_figure.R | head -n 1 | cut -f 3- -d ' ')

        BUSCO_VERSION=\$(busco --version | cut -f 2 -d ' ')
        echo "Busco-Version: \${BUSCO_VERSION}" >> busco_tool_info.txt

        BUSCO_DB_VERSION=\$(head -n 2 ${name}_busco_results/run_\${DATASET_BASENAME}/full_table.tsv | tail -n 1 | cut -f 2- -d ':' | sed "s/^ //")
        echo "DB-Version(s): \${BUSCO_DB_VERSION}" >> busco_tool_info.txt

        COMMAND_TEXT=\$(echo "busco -in ${fasta} --lineage_dataset \${DATASET_BASENAME} --offline --download_path ${busco_db_dir}/ --out ${name}_busco_results --mode genome")
        echo "Used Command: \${COMMAND_TEXT}" >> busco_tool_info.txt

        cat busco_tool_info.txt >> busco_tool_info_for_report.txt
        echo "\${PLOT_ABSOLUTE_VALUES}" | tr -d 'c() ' >> busco_tool_info_for_report.txt
        """  
    stub:
        """
        mkdir ${name}_busco_results
        touch ${name}_busco_results.tsv
        touch busco_tool_info.txt
        touch busco_tool_info_report.txt

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
        busco_db_basename = params.busco_db.split("\\.")[0]
        """
        mkdir -p busco_downloads/lineages busco_downloads/placement_files
        touch busco_downloads/file_versions.tsv
        touch busco_downloads/lineages/bacteria_odb10
        """
}