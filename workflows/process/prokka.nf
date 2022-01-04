/* Unused - annotation pipepline is utilizing bakta now */
process prokka {
    label 'prokka'
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.tsv"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.gff"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.txt"
	publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.gbk"

    input:
    	tuple val(name), path(dir)
    output:
    	tuple val(name), path("${name}_prokka.tsv"), path("prokka_version.txt"), emit: prokka_tsv_ch
    	tuple val(name), path("${name}_prokka.gff"), emit: prokka_report_ch
    	tuple val(name), path("${name}_prokka.*"), emit: prokka_working_ch
    script:
        """
        prokka --compliant --fast\
            --outdir \$PWD \
            --force \
            --prefix "${name}_prokka" \
            --quiet ${dir} \
            --cpus ${task.cpus}

        echo "test" >> prokka_version.txt
        """
    stub:
        """
        touch ${name}_prokka.gff \
            ${name}_prokka.tsv \
            ${name}_prokka.gbk \
            prokka_version.txt
        """
}
