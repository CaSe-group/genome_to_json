process download_db {
    label 'download_db'
    storeDir 'databases/sourmash'
    
    output:
        path("*.json.gz")
    script:
        """
        wget -O gtdb-rs202.genomic.k31.lca.json.gz https://osf.io/9xdg2/download 
        """
    stub:
        """
        touch gtdb-rs202.genomic.k31.lca.json.gz
        """
}
