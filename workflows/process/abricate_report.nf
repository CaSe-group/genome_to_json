process abricate_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(input), path(markdown)
    output:
        tuple val(name), path("${name}_report_abricate.Rmd"), path("${name}_report_abricate.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${input} ${name}_report_abricate.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_abricate.input/g' ${markdown} > ${name}_report_abricate.tmp
        sed -e 's/#NAMEENV#/${name}/g' ${name}_report_abricate.tmp > ${name}_report_abricate.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${input} ${name}_report_abricate.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_abricate.input/g' ${markdown} > ${name}_report_abricate.tmp
        sed -e 's/#NAMEENV#/${name}/g' ${name}_report_abricate.tmp > ${name}_report_abricate.Rmd
        """
}