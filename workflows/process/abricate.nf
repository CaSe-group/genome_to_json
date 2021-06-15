process abricate {
    label 'abricate'
    publishDir "${params.output}/abricate/${name}/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
      maxRetries 5

    input:
      tuple val(name), path(dir)
    output:
      tuple val(name), path("*card.tsv"), emit: abricate_output_ch
    script:
      """
      abricate ${dir} --nopath --quiet --mincov 80 --db ncbi >> "${name}"_abricate_ncbi.tsv
      abricate ${dir} --nopath --quiet --mincov 80 --db card >> "${name}"_abricate_card.tsv
      abricate ${dir} --nopath --quiet --mincov 80 --db vfdb >> "${name}"_abricate_vfdb.tsv
      abricate ${dir} --nopath --quiet --mincov 80 --db ecoh >> "${name}"_abricate_ecoh.tsv
      """
}