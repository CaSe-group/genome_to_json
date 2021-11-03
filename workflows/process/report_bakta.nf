process bakta_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(input), val(version), val(resultspath), path(markdown)
    output:
        tuple val(name), path("${name}_report_bakta.Rmd"), path("${name}_report_bakta.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${input} ${name}_report_bakta.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_bakta.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' | \
        sed -e 's@#PATHENV#@${resultspath}@g' | \
        sed -e 's/#VERSIONENV#/${version}/g'  > ${name}_report_bakta.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${input} ${name}_report_bakta.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/ABC_report_bakta.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/TEST/g' | \
        sed -e 's@#PATHENV#@ABCD@g' | \
        sed -e 's/#VERSIONENV#/0.0/g'  > ${name}_report_bakta.Rmd
        """
}
