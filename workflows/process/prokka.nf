process prokka {
    label 'prokka'
    publishDir "${params.output}/2.prokka/", mode: 'copy', pattern: "${name}_prokka.tsv"
    errorStrategy 'retry'
      maxRetries 5

    input:
       tuple val(name), path(dir)

    output:
     tuple val(name), path("${name}_prokka/${name}_prokka.tsv"), emit: prokka_output_ch
    script:
      """

          prokka --compliant --outdir "${name}_prokka" --prefix "${name}_prokka" --quiet ${dir}

      """

}
