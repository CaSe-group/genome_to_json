process abricate {
    label 'abricate'
    publishDir "${params.output}/abricate/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
      maxRetries 5

    input:
      tuple val(name), path(dir)
    output:
      tuple val(name), path("*.tsv"), emit: abricate_tsv_ch
    script:
      """
      abricate ${dir} --nopath --quiet --mincov 80 --db ncbi >> "${name}"_abricate_results.tsv
      abricate ${dir} --nopath --quiet --mincov 80 --db card >> "${name}"_abricate_results.tsv
      abricate ${dir} --nopath --quiet --mincov 80 --db vfdb >> "${name}"_abricate_results.tsv
      abricate ${dir} --nopath --quiet --mincov 80 --db ecoh >> "${name}"_abricate_results.tsv
      """
}