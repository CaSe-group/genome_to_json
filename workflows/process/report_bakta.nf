process bakta_report {
        label 'ubuntu'  
    input:
        tuple val(name), val(version), val(db_version), val(command), path(result_file), path(markdown)
    output:
        tuple val(name), path("${name}_report_bakta.Rmd"), path("${name}_report_bakta.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${result_file} ${name}_report_bakta.input
        
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_bakta.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' | \
        sed -e 's/#TOOLVERSIONENV#/${version}/g' | \
        sed -e 's/#DBVERSIONENV#/${db_version}/g' | \
        sed -e 's|#COMMANDENV#|${command}|g' | \
        sed -e 's|#PATHENV#|${params.output}/${name}/3.bakta|g' > ${name}_report_bakta.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${result_file} ${name}_report_bakta.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/ABC_report_bakta.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/TEST/g' | \
        sed -e 's@#PATHENV#@ABCD@g' | \
        sed -e 's/#VERSIONENV#/0.0/g'  > ${name}_report_bakta.Rmd
        """
}
