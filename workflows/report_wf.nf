include { abricate_report } from './process/report_abricate'
include { bakta_report } from './process/report_bakta'
include { prokka_report } from './process/report_prokka'
include { sample_report } from './process/report_sample'
include { sourmash_report } from './process/report_sourmash'
include { summary } from './process/report'


workflow report_generation_full_wf {
    take: 
        abricate_report_ch // tuple val(fasta_basename), path(data_table), path(data_table2)
        bakta_report_ch  // tuple val(fasta_basename), path(data_table)
        prokka_report_ch // tuple val(fasta_basename), path(prokka_gff)
        sourmash_report_ch // tuple val(fasta_basename), path(data_table)
    main:
        // 0 load reports
            // sample and summary report
            sampleheaderreport = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sampleheader.Rmd", checkIfExists: true)
            report = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/Report.Rmd", checkIfExists: true)

        // 1 Create tool-specific reports per sample
            def tool_list = [] //initialize empty list to which the outputs of the tool-report channels are added

            if ( !params.abricate_off) { //check if tool is active
                abricatereport = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/abricate.Rmd", checkIfExists: true) //load "${tool}report"-template from rmarkdown-submodule
                abricate_report(abricate_report_ch.combine(abricatereport)) //create tool-specific report via process ${tool}_report 
                                                                            //from the results in "${tool}_report_ch" and the "${tool}report"-template:
                tool_list.add(abricate_report.out) //add output from "${tool}_report"-process to list
            }
            if ( !params.bakta_off) {
                baktareport = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/bakta.Rmd", checkIfExists: true)
                bakta_report(bakta_report_ch.combine(baktareport))
                tool_list.add(bakta_report.out)
            }
            if ( !params.prokka_off) {
                prokkareport = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/prokka.Rmd", checkIfExists: true)
                prokka_report(prokka_report_ch.combine(prokkareport))
                tool_list.add(prokka_report.out)
            }
            if ( !params.sourmash_off) {
                sourmashreport = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sourmash.Rmd", checkIfExists: true)
                sourmash_report(sourmash_report_ch.combine(sourmashreport))
                tool_list.add(sourmash_report.out)
            }

        //idea for simplifed code:
            //def tool_list = [abricate, bakta, prokka, sourmash] //eventually as param in config?
            //tool_list.eachWithIndex { tool, index ->
                //if ( !params.${tool}_off) {
                //    ${tool}report = Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/${tool}.Rmd", checkIfExists: true)
                //    ${tool}_report(${tool}_report_ch.combine(${tool}report))
                //    tool_list.add(${tool}_report.out)
                //
                //    if ( index == 0) { //need here another check if first tool in tool-list is deactivated -> so first acitve tool
                //    samplereportinput = ${tool}_report.out //if its the first element of the list open a new channel containing the element
                //    }
                //    else {
                //        samplereportinput = samplereportinput
                //                            .mix(${tool}_report.out) //if its not the first list-element add it to the created channel
                //    }
                //}
            //}

        // 2 collect tool reports PER sample (add new via .mix(NAME_report.out))
            tool_list.eachWithIndex { element, index -> //loop over each element of the list getting the element itself and its index
                if ( index == 0) {
                    samplereportinput = element //if its the first element of the list open a new channel containing the element
                }
                else {
                    samplereportinput = samplereportinput
                                        .mix(element) //if its not the first list-element add it to the created channel
                }
            }

            samplereportinput = samplereportinput.groupTuple(by: 0)
                                .map{it -> tuple (it[0],it[1],it[2].flatten())}
            //samplereportinput.view()
            sample_report(samplereportinput.combine(sampleheaderreport))


        // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report)
            
}