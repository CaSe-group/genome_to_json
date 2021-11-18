include { bakta_report } from './process/report_bakta'
include { abricate_report } from './process/report_abricate'
include { sourmash_report } from './process/report_sourmash'
include { sample_report } from './process/report_sample'
include { summary } from './process/report'


workflow report_generation_full_wf {
    take: bakta_report_ch  // val(name), path(data_table)
          abricate_report_ch // val(name), path(data_table), path(data_table2)
          sourmash_report_ch // val(name), path(data_table)
    main:
        // 0 load reports
            // toolreports
            sourmashreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sourmash.Rmd", checkIfExists: true)
            abricatereport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/abricate.Rmd", checkIfExists: true)
            baktareport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/bakta.Rmd", checkIfExists: true)
            // sample and summary report
            sampleheaderreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sampleheader.Rmd", checkIfExists: true)
            report=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/Report.Rmd", checkIfExists: true)

        // 1 create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
        //    sourmash_report(sourmash_report_ch.combine(sourmashreport))
        //    abricate_report(abricate_report_ch.combine(abricatereport))
        //    bakta_report(bakta_report_ch.combine(baktareport))
        

        //alternative approach
            def tool_list = []

            if ( !params.abricate_off) {
                abricatereport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/abricate.Rmd", checkIfExists: true)
                abricate_report(abricate_report_ch.combine(abricatereport))
                tool_list.add(abricate_report.out)
            }
            if ( !params.bakta_off) {
                baktareport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/bakta.Rmd", checkIfExists: true)
                bakta_report(bakta_report_ch.combine(baktareport))
                tool_list.add(bakta_report.out)
            }
            //if ( !params.prokka_off) {
            //    prokkareport=
            //    prokka_report()
            //    tool_list.add(prokka_report.out)
            //}
            if ( !params.sourmash_off) {
                sourmashreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sourmash.Rmd", checkIfExists: true)
                sourmash_report(sourmash_report_ch.combine(sourmashreport))
                tool_list.add(sourmash_report.out)
            }

        // 2 collect tool reports PER sample (add new via .mix(NAME_report.out))
            tool_list.eachWithIndex { element, index ->
                if ( index == 0) {
                    samplereportinput = element
                }
                else {
                    samplereportinput = samplereportinput
                                        .mix(element)
                }
            }
            //samplereportinput =     sourmash_report.out
            //                        .mix(abricate_report.out)// maybe loop here? if tool active add to a list and than loop through list
            //                        .mix(bakta_report.out)
            //                        .groupTuple(by: 0)
            //                        .map{it -> tuple (it[0],it[1],it[2].flatten())}
            samplereportinput = samplereportinput.groupTuple(by: 0)
                                .map{it -> tuple (it[0],it[1],it[2].flatten())}
            samplereportinput.view()
            sample_report(samplereportinput.combine(sampleheaderreport))


        // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report)

}