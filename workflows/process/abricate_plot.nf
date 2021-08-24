process abricate_plot {
    label 'ggplot2'
    publishDir "${params.output}/${name}/ABR-Screening/", mode: 'copy', pattern: "*.pdf"
	errorStrategy { task.exitStatus in 1..1 ? 'ignore' : 'terminate'}
  	
	input:
    	tuple val(name), val(abricate_db), path(dir) 
  	output:
		tuple val(name), val(abricate_db), path("*.pdf"), optional: true
  	script:
		"""
		#!/usr/bin/Rscript

		library(ggplot2)
		
		inputdata <- read.table("${dir}", header = TRUE, sep = ";")
		
		pdf("classification-${abricate_db}.pdf", height = 6, width = 10)
		ggplot(data=inputdata, aes(x=type, y=amount, fill=group)) +
		geom_bar(stat="identity") +
		theme(legend.position = "none") +
		facet_wrap(~ group, scales = "free_y") + coord_flip()
		dev.off()
		"""
	stub:
		"""
		touch "${name}"_"${abricate_db}".pdf
		"""
}