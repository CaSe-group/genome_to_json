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
    publishDir "${params.output}/${name}/2.pgap", mode: 'copy'
    input: 
        tuple val(name), path(fasta)
        val(species)
        path(pgap_db)

    output: 
        tuple val(name),path("annot*"),path("VERSION") 
    script:
        """
        bash yaml_creator.sh ${fasta} "${species}"
        echo '${params.pgap_v}' > VERSION
        
        mkdir /pgap/pgap/input
        tar xzf ${pgap_db} --directory "/pgap/pgap/input" --strip-components=1
        rm ${pgap_db}
        cwltool /pgap/pgap/pgap.cwl --fasta ${fasta} --ignore_all_errors --report_usage --submol meta.yaml
        """
    stub:
        """ 
        touch annot.faa \
              annot.gff
        """
}

