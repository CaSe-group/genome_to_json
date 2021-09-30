process sourmash_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(input_tax), path(input_tax_meta), path(markdown)
    output:
        tuple val(name), path("${name}_report_sourmash.Rmd"), path("${name}_report_sourmash.*.input")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${input_tax} ${name}_report_sourmash.1.input
        cp ${input_tax_meta} ${name}_report_sourmash.2.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_sourmash.1.input/g' ${markdown} | \
        sed -e 's/#RESULTSENVMETA#/${name}_report_sourmash.2.input/g' | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_sourmash.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp ${input_tax} ${name}_report_sourmash.1.input
        cp ${input_tax_meta} ${name}_report_sourmash.2.input

        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_sourmash.1.input/g' ${markdown} | \
        sed -e 's/#RESULTSENVMETA#/${name}_report_sourmash.2.input/g' | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_sourmash.Rmd
        """
}