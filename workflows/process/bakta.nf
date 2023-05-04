process bakta {
    label 'bakta'
    publishDir "${params.output}/${name}/2.bakta", mode: 'copy'

    input:
        tuple val(name), path(fasta) 
        file(database) 
    output:
        tuple val(name), env(BAKTA_VERSION), env(BAKTA_DB_VERSION), env(COMMAND_TEXT), file("${name}_bakta.gff3"), emit: bakta_report_ch
        tuple val(name), file("${name}_bakta.tsv"), path("bakta_tool_info.txt"), emit: bakta_file_ch
        path("${name}_bakta*"), emit: bakta_publish_ch
    script:
        """
        tar xzf ${database}
        rm ${database}

        amrfinder_update --force_update --database db/amrfinderplus-db/
        bakta --output \$PWD --prefix ${name}_bakta --db \$PWD/db --keep-contig-headers --threads ${task.cpus} ${fasta}

        # reduce fingerprint on local systems
        rm -rf db

        BAKTA_VERSION=\$(bakta --version | cut -d ' ' -f2-)
        echo "Bakta-Version: \${BAKTA_VERSION}" >> bakta_tool_info.txt

        BAKTA_DB_VERSION=\$(echo "WIP")
        echo "DB-Version(s): \${BAKTA_DB_VERSION}" >> bakta_tool_info.txt

        COMMAND_TEXT=\$(echo "amrfinder_update --force_update --database db/amrfinderplus-db/; bakta --output \$PWD --prefix ${name}_bakta --db \$PWD/db --keep-contig-headers --threads ${task.cpus} ${fasta}")
        echo "Used Command: \${COMMAND_TEXT}" >> bakta_tool_info.txt
        """
    stub:
        """
        mkdir ${name}
        mkdir ${name}_bakta_results
        
        touch ${name}/2.bakta \
            ${name}_bakta.gff3 \
            ${name}_bakta.tsv \
            bakta_tool_info.txt
        """
}

process bakta_database {
    label 'ubuntu'
    storeDir "${params.databases}/bakta-7669534"   

    output:
        path("db.tar.gz")
    script:
        """
        # when updating database update number in storeDir
        wget --no-check-certificate https://zenodo.org/record/7669534/files/db.tar.gz
        export BAKTA_DB=./db
        """
    stub:
        """
        touch db.tar.gz
        """
    }


