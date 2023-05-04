process sourmash_report {
        label 'ubuntu'  
    input:
        tuple val(name), val(version), val(db_version), val(command), path(result_file_tax), path(result_file_meta), path(markdown)
    output:
        tuple val(name), path("${name}_report_sourmash.Rmd"), path("${name}_report_sourmash.*.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${result_file_tax} ${name}_report_sourmash.1.input
        cp ${result_file_meta} ${name}_report_sourmash.2.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_sourmash.1.input/g' ${markdown} | \
        sed -e 's/#RESULTSENVMETA#/${name}_report_sourmash.2.input/g' | \
        sed -e 's/#NAMEENV#/${name}/g' | \
        sed -e 's/#TOOLVERSIONENV#/${version}/g' | \
        sed -e 's/#DBVERSIONENV#/${db_version}/g' | \
        sed -e 's|#COMMANDENV#|${command}|g' | \
        sed -e 's|#PATHENV#|${params.output}/${name}/7.sourmash|g' > ${name}_report_sourmash.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${result_file_tax} ${name}_report_sourmash.1.input
        cp ${result_file_meta} ${name}_report_sourmash.2.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_sourmash.1.input/g' ${markdown} | \
        sed -e 's/#RESULTSENVMETA#/${name}_report_sourmash.2.input/g' | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_sourmash.Rmd
        """
}