process abricate {
    label 'abricate'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
        maxRetries 5

    input:
        tuple val(name), path(dir)
        each abricate_db
    output:
        tuple val(name), path("abricate_version_with_*.txt"), path("abricate_*_version.txt"), path("abricate_*_command.txt"), path("*abricate_ncbi.tsv"), optional: true, emit: abricate_ncbi_ch  //main output-channel if according file was created
        tuple val(name), path("abricate_version_with_*.txt"), path("abricate_*_version.txt"), path("abricate_*_command.txt"), path("*abricate_*.tsv"), optional: true, emit: abricate_deep_json_ch
        tuple val(name), val(abricate_db), path("*.tsv"), emit: abricate_files_ch //secondary output-channel to activate publishDir & feed res-parser
    script:
        if (! params.abricate_update)
        """
        abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> "${name}"_abricate_"${abricate_db}".tsv

        echo "abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> ${name}_abricate_${abricate_db}.tsv" >> abricate_${abricate_db}_command.txt

        abricate --version >> abricate_version_with_${abricate_db}.txt
        abricate --list | grep "${abricate_db}" | cut -f 1,4 | tr "\t" "_" >> abricate_${abricate_db}_version.txt
        """
        else if (params.abricate_update)
        """
        abricate-get_db --db ${abricate_db} --force
        abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> "${name}"_abricate_"${abricate_db}".tsv
        
        echo "abricate-get_db --db ${abricate_db} --force" >> abricate_${abricate_db}_command.txt
        echo "abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> ${name}_abricate_${abricate_db}.tsv" >> abricate_${abricate_db}_command.txt

        abricate --version >> abricate_version_with_${abricate_db}.txt
        abricate --list | grep "${abricate_db}" | cut -f 1,4 | tr "\t" "_" >> abricate_${abricate_db}_version.txt
        """
    stub:
        """
        touch "${name}"_abricate_"${abricate_db}".tsv \
            abricate_version_with_${abricate_db}.txt \
            abricate_${abricate_db}_command.txt \
            abricate_${abricate_db}_version.txt
        """
}

process abricate_combiner {
    label 'abricate'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy'
    errorStrategy 'retry'
        maxRetries 5

    input:
        tuple val(name), path(abricate_version_files), path(db_version_files), path(command_files), path(result_files)
    output:
        tuple val(name), path("abricate_tool_info.txt"), path("*abricate_combined_results.tsv"), emit: abricate_combiner_file_ch  //main output-channel with all files
        tuple val(name), env(ABRICATE_VERSION), env(DB_VERSION), env(COMMAND_TEXT), path("*abricate_combined_results.tsv"), emit: abricate_combiner_report_ch  //output-channel for Rmarkdown-creation
    script:
        """
        printf "#FILE	SEQUENCE	START	END	STRAND	GENE	COVERAGE	COVERAGE_MAP	GAPS	%%COVERAGE	%%IDENTITY	DATABASE	ACCESSION	PRODUCT	RESISTANCE\\n" >> "${name}"_abricate_combined_results.tsv
        tail -q -n +2 *.tsv >> "${name}"_abricate_combined_results.tsv

        ABRICATE_VERSION=\$(cat abricate_version_with_*.txt | uniq | cut -f 2 -d ' ')
        echo "ABRicate-Version: \${ABRICATE_VERSION}" >> abricate_tool_info.txt

        DB_VERSION=\$(cat abricate_*_version.txt | sed -z "s/\\n/; /g" | sed "s/; \\\$//g")
        echo "DB-Version(s): \${DB_VERSION}" >> abricate_tool_info.txt

        COMMAND_TEXT=\$(cat abricate_*_command.txt | sed "s/--db .* >>/--db \\\${abricate_db} >>/g" | sed "s/--db .* --/--db \\\${abricate_db} --/g" | sed "s/_abricate_.*.tsv/_abricate_\\\${abricate_db}.tsv/g" | sed -z "s/--force\\n/--force; /g" | uniq)
        echo "Used Command: \${COMMAND_TEXT}" >> abricate_tool_info.txt 
        """
    stub:
        """
        touch "${name}"_abricate_combined_results.tsv \
            abricate_tool_info.txt
        """
}