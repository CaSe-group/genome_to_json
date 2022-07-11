process eggnog_db_download {
    label 'eggnog'
    storeDir "${params.databases}/eggnog"
    
    // output: 
    //     path(eggnog_db)
    script:
        """
        download_eggnog_data.py --data-dir ${params.databases}/eggnog/
        """  
    stub:
        """
        touch ${name}_eggnog.tsv
        """
}

process eggnog_emapper {
    label 'eggnog'
    publishDir "${params.output}/${name}/${params.eggnogdir}", mode: 'copy', pattern: "*"
    
    input:
        tuple val(name), path(fasta)
    output: 
        tuple val(name), path("${name}_eggnog_results"), env(EGGNOG_VERSION)
    script:
        """
        emapper.py --i ${fasta} \
            -m diamond \
            --data_dir ${params.databases}/eggnog/ \
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
            -o ${name}_eggnog_results
        
        EGGNOG_VERSION=\$(eggnog --version) 
        """  
    stub:
        """
        touch ${name}_eggnog_results
        EGGNOG_VERSION=stub
        """
}