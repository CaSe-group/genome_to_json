/* Unused - annotation pipepline is utilizing bakta now */
process prokka {
    label 'prokka'
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.tsv"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.gff"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.txt"
	publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "${name}_prokka.gbk"
    publishDir "${params.output}/${name}/${params.prokkadir}/", mode: 'copy', pattern: "prokka_tool_info.txt"

    input:
    	tuple val(name), path(dir)
    output:
    	tuple val(name), path("${name}_prokka.tsv"), path("prokka_tool_info.txt"), emit: prokka_file_ch
    	tuple val(name), env(PROKKA_VERSION), env(PROKKA_DB_VERSION), env(COMMAND_TEXT), path("${name}_prokka.gff"), emit: prokka_report_ch
    	tuple val(name), path("${name}_prokka.*"), emit: prokka_working_ch
    script:
        """
        prokka --compliant \
            --fast \
            --outdir \$PWD \
            --force \
            --prefix "${name}_prokka" \
            --quiet ${dir} \
            --cpus ${task.cpus}

        PROKKA_VERSION=\$(prokka --version 2>&1 | cut -f 2 -d ' ')
        echo "Prokka-Version: \${PROKKA_VERSION}" >> prokka_tool_info.txt
        
        PROKKA_DB_VERSION=\$(echo "WIP")
        echo "DB-Version(s): \${PROKKA_DB_VERSION}" >> prokka_tool_info.txt

        COMMAND_TEXT=\$(echo "prokka --compliant --fast --outdir \$PWD --force --prefix "${name}_prokka" --quiet ${dir} --cpus ${task.cpus}")
        echo "Used Command: \${COMMAND_TEXT}" >> prokka_tool_info.txt
        """
    stub:
        """
        touch ${name}_prokka.gff \
            ${name}_prokka.tsv \
            ${name}_prokka.gbk \
            prokka_tool_info.txt
        """
}
