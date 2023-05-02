process busco_report {
        label 'ubuntu'  
    input:
        tuple val(name), val(busco_version), val(busco_db_version), val(command), val(plot_percentage_values), val(plot_absolute_values), path(result_file), path(markdown)
    output:
        tuple val(name), path("${name}_report_busco.Rmd"), path("${name}_report_busco.input")
    script:
        """
        # rename result file to avoid collisions later (needs to be ".input")
        cp ${result_file} ${name}_report_busco.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_busco.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' | \
        sed -e 's/#TOOLVERSIONENV#/${busco_version}/g' | \
        sed -e 's/#DBVERSIONENV#/${busco_db_version}/g' | \
        sed -e 's|#COMMANDENV#|${command}|g' | \
        sed -e 's|#PATHENV#|${params.output}|g' | \
        sed -e 's|#PLOT_SPECIES#|c("${name}", "${name}", "${name}", "${name}")|' | \
        sed -e 's|#PLOT_PERCENTAGE_VALUES#|${plot_percentage_values}|' | \
        sed -e 's|#PLOT_ABSOLUTE_VALUES#|${plot_absolute_values}|' > ${name}_report_busco.Rmd
        """
    stub:
        """
        # rename result file to avoid collisions later
        cp ${result_file} ${name}_report_busco.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_busco.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_busco.Rmd
        """
}