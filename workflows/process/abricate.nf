process abricate {
    label 'abricate'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
        maxRetries 5

    input:
        tuple val(name), path(dir)
        each abricate_db
    output:
        tuple val(name), path("abricate_*_version.txt"), path("abricate_*_command.txt"), path("*abricate_ncbi.tsv"), optional: true, emit: abricate_ncbi_output_ch  //main output-channel if according file was created
        tuple val(name), path("abricate_*_version.txt"), path("abricate_*_command.txt"), path("*abricate_*.tsv"), optional: true, emit: abricate_deep_json_output_ch
        tuple val(name), val(abricate_db), path("*.tsv"), emit: abricate_files_ch //secondary output-channel to activate publishDir & feed res-parser
    script:
        if (! params.abricate_update)
        """
        abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> "${name}"_abricate_"${abricate_db}".tsv

        echo "abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> ${name}_abricate_${abricate_db}.tsv" >> abricate_${abricate_db}_command.txt

        abricate --list | grep "${abricate_db}" | cut -f 1,4 | tr "\t" "_" >> abricate_${abricate_db}_version.txt
        """
        else if (params.abricate_update)
        """
        abricate-get_db --db ${abricate_db} --force
        abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> "${name}"_abricate_"${abricate_db}".tsv
        
        echo "abricate-get_db --db ${abricate_db} --force" >> abricate_${abricate_db}_command.txt
        echo "abricate ${dir} --nopath --quiet --mincov ${params.abricate_coverage} --minid ${params.abricate_identity} --db ${abricate_db} >> ${name}_abricate_${abricate_db}.tsv" >> abricate_${abricate_db}_command.txt

        abricate --list | grep "${abricate_db}" | cut -f 1,4 | tr "\t" "_" >> abricate_${abricate_db}_version.txt
        """
    stub:
        """
        printf "#FILE	SEQUENCE	START	END	STRAND	GENE	COVERAGE	COVERAGE_MAP	GAPS	%%COVERAGE	%%IDENTITY	DATABASE	ACCESSION	PRODUCT	RESISTANCE\\n" >> "${name}"_abricate_"${abricate_db}".tsv
        printf "S.126.21.Cf.fasta	S.126.21.Cf_contig35	15020	15820	-	blaVIM-1	1-801/801	===============	0/0	100.00	100.00	ncbi	NG_050336.1	subclass B1 metallo-beta-lactamase VIM-1	CARBAPENEM\\n" >> "${name}"_abricate_"${abricate_db}".tsv
        printf "S.126.21.Cf.fasta	S.126.21.Cf_contig35	14358	14912	-	aac(6')-Ib-G	1-555/555	===============	0/0	100.00	99.82	ncbi	NG_052361.1	AAC(6')-Ib family aminoglycoside 6'-N-acetyltransferase	GENTAMICIN\\n" >> "${name}"_abricate_"${abricate_db}".tsv
        
        touch abricate_${abricate_db}_command.txt
        touch abricate_${abricate_db}_version.txt
        """
}

process abricate_combiner {
    label 'abricate'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy'
    errorStrategy 'retry'
        maxRetries 5

    input:
        tuple val(name), path(db_version_files), path(command_files), path(result_files)
    output:
        tuple val(name), path("abricate_db_version.txt"), path("abricate_command.txt"), path("*abricate_combined_results.tsv"), emit: abricate_combiner_output_ch  //main output-channel if according file was created
    script:
        """
        printf "#FILE	SEQUENCE	START	END	STRAND	GENE	COVERAGE	COVERAGE_MAP	GAPS	%%COVERAGE	%%IDENTITY	DATABASE	ACCESSION	PRODUCT	RESISTANCE\\n" >> "${name}"_abricate_combined_results.tsv
        tail -q -n +2 *.tsv >> "${name}"_abricate_combined_results.tsv

        cat abricate_*_command.txt | sed "s/--db .* >>/--db \\\${abricate_db} >>/g" | sed "s/--db .* --/--db \\\${abricate_db} --/g" | sed "s/_abricate_.*.tsv/_abricate_\\\${abricate_db}.tsv/g" | sed -z "s/--force\\n/--force; /g" | uniq  >> abricate_command.txt 

        cat abricate_*_version.txt >> abricate_db_version.txt
        """
    stub:
        """
        printf "#FILE	SEQUENCE	START	END	STRAND	GENE	COVERAGE	COVERAGE_MAP	GAPS	%%COVERAGE	%%IDENTITY	DATABASE	ACCESSION	PRODUCT	RESISTANCE\\n" >> "${name}"_abricate_combined_results.tsv

        touch abricate_ncbi_version.txt
        """
}