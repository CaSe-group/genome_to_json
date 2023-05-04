process eggnog_db_download {
    label 'eggnog'
    storeDir "${params.databases}/eggnog"
    errorStrategy 'retry'
        maxRetries 5
    
    output: 
        path("eggnog_db")
    script:
        """
        mkdir eggnog_db
        download_eggnog_data.py -y --data_dir eggnog_db/
        """  
    stub:
        """
        touch eggnog_db
        """
}

process eggnog_emapper {
    label 'eggnog'
    publishDir "${params.output}/${name}/${params.eggnogdir}", mode: 'copy', pattern: "*"
    
    input:
        tuple val(name), path(fasta)
        path(eggnog_db_dir)
    output: 
        tuple val(name), path("${name}_eggnog*"), path("eggnog_tool_info.txt"), emit: eggnog_file_ch
        tuple val(name), env(EGGNOG_VERSION), env(EGGNOG_DB_VERSION), env(COMMAND_TEXT), path("${name}_eggnog*"), emit: eggnog_report_ch
    script:
        """
        emapper.py -i ${fasta} \
            --cpu 14 \
            -m diamond \
            --data_dir ${eggnog_db_dir} \
            --itype genome \
            --genepred prodigal \
            --dmnd_ignore_warnings \
            --translate \
            --go_evidence non-electronic \
            --pfam_realign none \
            --report_orthologs \
            --evalue 0.001 \
            --score 60 \
            --pident 40 \
            --query_cover 20 \
            --subject_cover 20 \
            --tax_scope auto \
            --target_orthologs all \
            -o ${name}_eggnog
        
        EGGNOG_VERSION=\$(emapper.py --version)
        echo "Eggnog-Version: \${EGGNOG_VERSION}" >> eggnog_tool_info.txt

        EGGNOG_DB_VERSION=\$(echo "${eggnog_db_dir}")
        echo "DB-Version(s): \${EGGNOG_DB_VERSION}" >> eggnog_tool_info.txt

        COMMAND_TEXT=\$(echo "emapper.py -i ${fasta} --cpu 14 -m diamond --data_dir ${eggnog_db_dir} --itype genome --genepred prodigal --dmnd_ignore_warnings --translate --go_evidence non-electronic --pfam_realign none --report_orthologs --evalue 0.001 --score 60 --pident 40 --query_cover 20 --subject_cover 20 --tax_scope auto --target_orthologs all -o ${name}_eggnog")
        echo "COMMAND used: \${COMMAND_TEXT}" >> eggnog_tool_info.txt
        """  
    stub:
        """
        touch ${name}_eggnog \
            eggnog_tool_info.txt
        """
}