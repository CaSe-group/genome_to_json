process prokka {
    label 'prokka'
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.tsv"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.gff"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.txt"
	publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka/${name}_prokka.gbk"
    errorStrategy 'retry'
    	maxRetries 5

    input:
    	tuple val(name), path(dir)
    output:
    	tuple val(name), path("${name}_prokka/${name}_prokka.tsv"), env(PROKKA_VERSION), emit: prokka_tsv_ch
    	tuple val(name), path("${name}_prokka/${name}_prokka.*"), emit: prokka_working_ch
    script:
    	"""
    	prokka --compliant --fast\
            --outdir "${name}_prokka" \
            --prefix "${name}_prokka" \
            --quiet ${dir}
    	
        PROKKA_VERSION=\$(cat /opt/conda/pkgs/prokka*/bin/prokka | grep 'my \$VERSION =' | cut -f4 -d ' ' | tr -d '"' | tr -d ';')
        """
    stub:
        """
        mkdir -p ${name}_prokka
        touch ${name}_prokka/${name}_prokka.tsv \
            ${name}_prokka/${name}_prokka.gbk
        
        PROKKA_VERSION=stub
        """
}