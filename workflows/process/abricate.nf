process abricate {
    label 'abricate'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
        maxRetries 5

    input:
        tuple val(name), path(dir)
        each abricate_db
    output:
        tuple val(name), path("*abricate_ncbi.tsv"), path("abricate_ncbi_version.txt"), optional: true, emit: abricate_output_ch  //main output-channel if according file was created
        tuple val(name), val(abricate_db), path("*.tsv"), emit: abricate_files_ch //secondary output-channel to activate publishDir & feed res-parser
    script:
        """
        abricate ${dir} --nopath --quiet --mincov 80 --db ${abricate_db} >> "${name}"_abricate_"${abricate_db}".tsv
        
        abricate --list | grep "ncbi" | cut -f 1,4 | tr "\t" "_" >> abricate_ncbi_version.txt
        """
    stub:
        """
        printf "#FILE	SEQUENCE	START	END	STRAND	GENE	COVERAGE	COVERAGE_MAP	GAPS	%%COVERAGE	%%IDENTITY	DATABASE	ACCESSION	PRODUCT	RESISTANCE\\n" >> "${name}"_abricate_"${abricate_db}".tsv
        printf "S.126.21.Cf.fasta	S.126.21.Cf_contig35	15020	15820	-	blaVIM-1	1-801/801	===============	0/0	100.00	100.00	ncbi	NG_050336.1	subclass B1 metallo-beta-lactamase VIM-1	CARBAPENEM\\n" >> "${name}"_abricate_"${abricate_db}".tsv
        printf "S.126.21.Cf.fasta	S.126.21.Cf_contig35	14358	14912	-	aac(6')-Ib-G	1-555/555	===============	0/0	100.00	99.82	ncbi	NG_052361.1	AAC(6')-Ib family aminoglycoside 6'-N-acetyltransferase	GENTAMICIN\\n" >> "${name}"_abricate_"${abricate_db}".tsv
        
        touch abricate_ncbi_version.txt
        """
}