include { abricate_report } from './process/report_abricate'
include { bakta_report } from './process/report_bakta'
include { busco_report} from './process/report_busco'
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
        pgap_report_ch   
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
                                    'pgap'  : pgap_report_ch,
                                    'prokka' : prokka_report_ch,
                                    'sourmash' : sourmash_report_ch
                                    ]

            def tool_list = channel_input_dict.keySet() as ArrayList
            def active_tool_list = []
            tool_list.each { tool ->
                if ( evaluate("params.${tool}") ) {
                    active_tool_list += tool
                }
            }

        // 2 Create tool-specific reports per sample
            samplereportinput = Channel.empty()

            active_tool_list.each { active_tool ->
                tool_report_check = new File("${workflow.projectDir}" + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/${active_tool}.Rmd")
                if ( tool_report_check.exists() == true ) {
                    tool_report_template_ch = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/${active_tool}.Rmd", checkIfExists: true)
                    tool_result_ch = channel_input_dict["${active_tool}"]
                    samplereportinput = samplereportinput.mix("${active_tool}_report"(tool_result_ch.combine(tool_report_template_ch)))
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