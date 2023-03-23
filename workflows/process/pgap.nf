process pgap_database {
    label 'ubuntu'
    storeDir "${params.databases}/pgap"   
    input: 
        val pgap_v
    output:
        path("input-${params.pgap_v}.tgz")

    script:
        """
        wget --no-check-certificate https://s3.amazonaws.com/pgap/input-${params.pgap_v}.tgz
        """
    stub:
        
        touch input-${params.pgap_v}.tgz
        
    }

process pgap {
    label 'pgap'
    input: 
        tuple val(name), path(fasta), val(species)
        path(pgap_db)

    output: 
        tuple val(name), path("${name}_pgap.faa"), path("${name}_pgap.gff",) path("annot_*"), emit: pgap_output_ch
        publishDir "${params.output}/${name}/2.pgap", mode: 'copy'
    script:
        """
        bash yaml_creator.sh ${fasta} "${species}"
        echo '${params.pgap_v}' > VERSION
        
        mkdir /pgap/pgap/input
        tar xzf ${pgap_db} --directory "/pgap/pgap/input" --strip-components=1
        rm ${pgap_db}
        
        cwltool /pgap/pgap/pgap.cwl --fasta ${fasta} --ignore_all_errors --report_usage --submol meta.yaml
        mv annot.faa ${name}_pgap.faa
        mv annot.gff ${name}_pgap.gff

        """
    stub:
        """ 
        touch ${name}_pgap.faa \
              ${name}_pgap.gff
        """
}