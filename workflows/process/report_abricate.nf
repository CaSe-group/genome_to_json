process abricate_report {
        label 'ubuntu'  
    input:
        tuple val(name), val(abricate_version), val(abricate_db_version), val(command), path(result_file), path(markdown)
    output:
        tuple val(name), path("${name}_report_abricate.Rmd"), path("${name}_report_abricate.input")
    script:
        """
        # rename result file to avoid collisions later (needs to be ".input")
        cp ${result_file} ${name}_report_abricate.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_abricate.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' | \
        sed -e 's/#TOOLVERSIONENV#/${abricate_version}/g' | \
        sed -e 's/#DBVERSIONENV#/${abricate_db_version}/g' | \
        sed -e 's|#COMMANDENV#|${command}|g' | \
        sed -e 's|#PATHENV#|${params.output}|g' > ${name}_report_abricate.Rmd
        """
    stub:
        """
        # rename result file to avoid collisions later
        cp ${result_file} ${name}_report_abricate.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_abricate.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_abricate.Rmd
        """
}