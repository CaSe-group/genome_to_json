/* Unused - annotation pipepline is utilizing bakta now */
process prokka {
    label 'prokka'
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.tsv"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.gff"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.txt"
	publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.gbk"

    input:
    	tuple val(name), path(dir)
    output:
    	tuple val(name), path("${name}_prokka/${name}_prokka.tsv"), env(PROKKA_VERSION), emit: prokka_tsv_ch
    	tuple val(name), path("${name}_prokka/${name}_prokka.gff"), emit: prokka_report_ch
    	tuple val(name), path("${name}_prokka/${name}_prokka.*"), emit: prokka_working_ch
    script:
    	"""
    	prokka --compliant --fast\
            --outdir "${name}_prokka" \
            --prefix "${name}_prokka" \
            --quiet ${dir} \
            --cpus ${task.cpus}

        PROKKA_VERSION=test
        """
    stub:
        """
        mkdir -p ${name}_prokka
        touch ${name}_prokka/${name}_prokka.gff \
            ${name}_prokka/${name}_prokka.tsv \
            ${name}_prokka/${name}_prokka.gbk
        
        PROKKA_VERSION=stub
        """
}
