include { prokka_report } from './process/report_prokka'
include { abricate_report } from './process/report_abricate'
include { sourmash_report } from './process/report_sourmash'
include { sample_report } from './process/report_sample'
include { summary } from './process/report'


workflow report_generation_full_wf {
    take: prokka_report_ch  // val(name), path(data_table)
          abricate_report_ch // val(name), path(data_table), path(data_table2)
          sourmash_report_ch // val(name), path(data_table)
    main:
        // 0 load reports
            // toolreports
            sourmashreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sourmash.Rmd", checkIfExists: true)
            abricatereport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/abricate.Rmd", checkIfExists: true)
            prokkareport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/prokka.Rmd", checkIfExists: true)
            // sample and summary report
            sampleheaderreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sampleheader.Rmd", checkIfExists: true)
            report=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/Report.Rmd", checkIfExists: true)


        // 1 create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
            sourmash_report(sourmash_report_ch.combine(sourmashreport))
            abricate_report(abricate_report_ch.combine(abricatereport))
            prokka_report(prokka_report_ch.combine(prokkareport))

        // 2 collect tool reports PER sample (add new via .mix(NAME_report.out))
            samplereportinput =     sourmash_report.out
                                    .mix(abricate_report.out)
                                    .mix(prokka_report.out)
                                    .groupTuple(by: 0)
                                    .map{it -> tuple (it[0],it[1],it[2].flatten())}

            sample_report(samplereportinput.combine(sampleheaderreport))


        // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report)

}