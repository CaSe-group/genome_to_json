process eggnog_db_download {
    label 'eggnog'
    storeDir "${params.databases}/eggnog"
    
    output: 
        path("*")
    script:
        """
        download_eggnog_data.py -y --data_dir \$PWD
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
        path(eggnog_db)
    output: 
        tuple val(name), path("${name}_eggnog*"), path("eggnog_version.txt")
    script:
        """
        emapper.py -i ${fasta} \
            -m diamond \
            --data_dir \$PWD \
            --itype genome \
            --genepred prodigal \
            --dmnd_ignore_warnings \
            --translate \
            --go_evidence non-electronic \
            --pfam_realign none \
            --report_orthologs \
            --decorate_gff yes \
            --evalue 0.001 \
            --score 60 \
            --pident 40 \
            --query_cover 20 \
            --subject_cover 20 \
            --tax_scope auto \
            --target_orthologs all \
            -o ${name}_eggnog
        
        emapper.py --version >> eggnog_version.txt
        """  
    stub:
        """
        touch ${name}_eggnog
        EGGNOG_VERSION=stub
        """
}