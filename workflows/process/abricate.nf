process abricate {
    label 'abricate'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
        maxRetries 5

    input:
        tuple val(name), path(dir)
        each abricate_db
    output:
        tuple val(name), path("*ncbi.tsv"), env(ABRICATE_DB_VERSION), optional: true, emit: abricate_output_ch  //main output-channel if according file was created
        tuple val(name), path("*.tsv"), emit: abricate_files_ch //secondary output-channel to activate publishDir
    script:
        """
        abricate ${dir} --nopath --quiet --mincov 80 --db ${abricate_db} >> "${name}"_abricate_"${abricate_db}".tsv
        
        ABRICATE_DB_VERSION=\$(abricate --list | grep "ncbi" | cut -f 1,4 | tr "\t" "_")
        """
    stub:
        """
        touch "${name}"_abricate_ncbi.tsv
        ABRICATE_DB_VERSION=stub
        """
}