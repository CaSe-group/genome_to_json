process gtdb_db_download {
        label 'ubuntu'
        storeDir "${params.databases}/gtdb"
    output:
        path("gtdbtk_data.tar.gz")
    script:
        """
        wget --no-check-certificate https://data.gtdb.ecogenomic.org/releases/latest/auxillary_files/gtdbtk_data.tar.gz
        """
    stub:
        """
        touch gtdbtk_data.tar.gz
        """
}
