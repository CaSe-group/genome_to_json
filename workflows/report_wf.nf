include { abricate_report } from './process/report_abricate'
include { bakta_report } from './process/report_bakta'
include { prokka_report } from './process/report_prokka'
include { sample_report } from './process/report_sample'
include { sourmash_report } from './process/report_sourmash'
include { summary } from './process/report'


workflow report_generation_full_wf {
    take: 
        abricate_report_ch // tuple val(fasta-basename) path(fasta-basename_abricate_ncbi.tsv)
        bakta_report_ch  // tuple val(fasta-basename), file(fasta-basename_bakta.gff3), path(bakta_version.txt), val("${params.output}/fasta-basename/2.bakta")
        busco_report_ch // tuple val(fasta-basename), 
        eggnog_report_ch // tuple val(fasta-basename), 
        prokka_report_ch // tuple val(fasta-basename), path(fasta-basename_prokka.gff
        sourmash_report_ch // tuple val(fasta-basename), path(fasta-basename_taxonomy.tsv), path(fasta-basename_composition.csv)
    main:
        
        // 0 load reports
        // sample and summary report
            sampleheaderreport = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sampleheader.Rmd", checkIfExists: true)
            report = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/Report.Rmd", checkIfExists: true)

        // 1 Collect tool output-channels & scan which tools are active
            def channel_input_dict = ['abricate' : abricate_report_ch,
                                    'bakta' : bakta_report_ch,
                                    'busco' : busco_report_ch,
                                    'eggnog' : eggnog_report_ch,
                                    'prokka' : prokka_report_ch,
                                    'sourmash' : sourmash_report_ch
                                    ]

            def active_tool_list = []
            file(workflow.projectDir + "/nextflow.config").getText().eachLine { line ->
                if (line.contains("_off")) {
                    tool_name = line.minus("_off = false").trim()
                    if ( ! evaluate("params.${tool_name}_off") ) {
                        active_tool_list += tool_name
                    }
                }
            }

        // 2 Create tool-specific reports per sample
            samplereportinput = Channel.empty()

            active_tool_list.each { tool ->
                tool_report_check = new File("${workflow.projectDir}" + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/${tool}.Rmd")
                if ( tool_report_check.exists() == true ) {
                    tool_report = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/${tool}.Rmd", checkIfExists: true)
                    //def tool_input_ch = evaluate("${tool}_report_ch".toString())
                    //binding.setProperty('${tool}_test_ch', tool_input_ch)
                    //"${tool}_test_ch".view()
                    tool_report_ch = channel_input_dict["${tool}"]
                    samplereportinput = samplereportinput.mix("${tool}_report"(tool_report_ch.combine(tool_report)))
                }
                else {
                    return
                }
            }

            samplereportinput = samplereportinput.groupTuple(by: 0)
                                .map{ it -> tuple (it[0],it[1],it[2].flatten()) }
                                //.view()
            sample_report(samplereportinput.combine(sampleheaderreport))

        // 3 sumarize sample reports in final report
            summary(sample_report.out.flatten().collect(), report)
}