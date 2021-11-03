process bakta {
      publishDir "${params.output}/${name}/2.bakta", mode: 'copy'
      label 'bakta' 
    input:
      tuple val(name), path(fasta) 
      file(database) 
    output:
      tuple val(name), file("${name}-results/${name}.gff3"), env(BAKTA_VERSION), val("${params.output}/${name}/2.bakta"), emit: bakta_report_ch
      tuple val(name), file("${name}-results/${name}.tsv"), env(BAKTA_VERSION), emit: bakta_json_ch
      path("${name}-results"), emit: bakta_publish_ch
    script:
      """
      tar xzf ${database}
      rm ${database}
      export BAKTA_DB=./db
      amrfinder_update --force_update --database db/amrfinderplus-db/
      bakta --output ${name}-results --threads ${task.cpus} ${fasta}
      # reduce fingerprint on local systems
      rm -rf db

      BAKTA_VERSION=\$(bakta --version | cut -d' ' -f2-)
      """
}


