process bakta {
    label 'bakta'
    publishDir "${params.output}/${name}/2.bakta", mode: 'copy'

    input:
        tuple val(name), path(fasta) 
        file(database) 
    output:
        tuple val(name), file("${name}_bakta.gff3"), path("bakta_version.txt"), val("${params.output}/${name}/2.bakta"), emit: bakta_report_ch
        tuple val(name), file("${name}_bakta.tsv"), path("bakta_version.txt"), emit: bakta_json_ch
        path("${name}_bakta*"), emit: bakta_publish_ch
    script:
        """
        tar xzf ${database}
        rm ${database}

        amrfinder_update --force_update --database db/amrfinderplus-db/
        bakta --output \$PWD --prefix ${name}_bakta --db \$PWD/db --keep-contig-headers --threads ${task.cpus} ${fasta}

        # reduce fingerprint on local systems
        rm -rf db

        bakta --version | cut -d ' ' -f2- >> bakta_version.txt
        """
    stub:
        """
        mkdir ${name}
        mkdir ${name}_bakta_results
        
        touch ${name}/2.bakta \
            ${name}_bakta.gff3 \
            ${name}_bakta.tsv \
            bakta_version.txt
        """
}

process bakta_database {
    label 'ubuntu'
    storeDir "${params.databases}/bakta-7025248"   

    output:
        path("db.tar.gz")
    script:
        """
        # when updating database update number in storeDir
        wget --no-check-certificate https://zenodo.org/record/7025248/files/db.tar.gz
        export BAKTA_DB=./db
        """
    stub:
        """
        touch db.tar.gz
        """
    }


