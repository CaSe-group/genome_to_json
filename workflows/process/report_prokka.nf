process prokka_report {
        label 'ubuntu'  
    input:
        tuple val(name), val(version), val(db_version), val(command), path(result_file), path(markdown)
    output:
        tuple val(name), path("${name}_report_prokka.Rmd"), path("${name}_report_prokka.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${result_file} ${name}_report_prokka.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_prokka.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' | \
        sed -e 's/#TOOLVERSIONENV#/${version}/g' | \
        sed -e 's/#DBVERSIONENV#/${db_version}/g' | \
        sed -e 's|#COMMANDENV#|${command}|g' | \
        sed -e 's|#PATHENV#|${params.output}/${name}/6.prokka|g' > ${name}_report_prokka.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${result_file} ${name}_report_prokka.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_prokka.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_prokka.Rmd
        """
}