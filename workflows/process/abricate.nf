process abricate {
    label 'abricate'
    publishDir "${params.output}/${name}/2.abricate/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
      maxRetries 5

    input:
        tuple val(name), path(dir)
    output:
        tuple val(name), path("*ncbi.tsv"), env(ABRICATE_DB_VERSION), emit: abricate_output_ch
    script:
        """
        abricate ${dir} --nopath --quiet --mincov 80 --db ncbi >> "${name}"_abricate_ncbi.tsv
        abricate ${dir} --nopath --quiet --mincov 80 --db card >> "${name}"_abricate_card.tsv
        abricate ${dir} --nopath --quiet --mincov 80 --db vfdb >> "${name}"_abricate_vfdb.tsv
        abricate ${dir} --nopath --quiet --mincov 80 --db ecoh >> "${name}"_abricate_ecoh.tsv
        
        ABRICATE_DB_VERSION=\$(abricate --list | grep "ncbi" | cut -f 1,4 | tr "\t" "_")
        """
}