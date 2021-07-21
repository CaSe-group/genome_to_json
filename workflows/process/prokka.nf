process prokka {
    label 'prokka'
    publishDir "${params.output}/${name}/3.prokka/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.tsv"
    publishDir "${params.output}/${name}/3.prokka/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.gff"
    publishDir "${params.output}/${name}/3.prokka/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.txt"
    errorStrategy 'retry'
      maxRetries 5

    input:
       tuple val(name), path(dir)

    output:
     tuple val(name), path("${name}_prokka/${name}_prokka.tsv"), emit: prokka_tsv_ch
     tuple val(name), path("${name}_prokka/${name}_prokka.*"), emit: prokka_working_ch
    script:
      """

          prokka --compliant --outdir "${name}_prokka" --prefix "${name}_prokka" --fast --quiet ${dir}

      """

}
