process prokka_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(input), path(markdown)
    output:
        tuple val(name), path("${name}_report_prokka.Rmd"), path("${name}_report_prokka.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${input} ${name}_report_prokka.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_prokka.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g'  > ${name}_report_prokka.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${input} ${name}_report_prokka.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_prokka.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_prokka.Rmd
        """
}