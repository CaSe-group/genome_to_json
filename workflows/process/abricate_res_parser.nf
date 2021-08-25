process abricate_res_parser {
    label 'ubuntu'
    publishDir "${params.output}/${name}/${params.abricatedir}/", mode: 'copy', pattern: '*.csv'
        errorStrategy 'retry'
        maxRetries 5
	
	input:
    	tuple val(name), val(abricate_db), path(dir) 
  	output:
	  	tuple val(name), val(abricate_db), file("*.csv") 
  	script:
		"""
		printf "amount;type;group\\n" > "${name}"_"${abricate_db}".csv
		
		# beta-lactamase
		blaData=\$(tail -n+2 ${dir} | grep -E "bla[A-Z]|lactamase" | cut -f6 | sort | uniq -c |\
			sed -e 's/^[ \\t]*//' | tr " " ";" | sed -e 's/\$/;beta-lactamase/') 
		printf "\${blaData}\\n" >> "${name}"_"${abricate_db}".csv
		
		# tetracycline
		tetData=\$(tail -n+2 ${dir} | grep "tetracycline" | cut -f6 | grep -v "bla" | sort |\
			uniq -c | sed -e 's/^[ \\t]*//'| tr -d "'" | tr " " ";" | sed -e 's/\$/;tetracycline-resistance/') 
		printf "\${tetData}\\n" >> "${name}"_"${abricate_db}".csv
		
		# aminoglycoside
		aminoData=\$(tail -n+2 ${dir} | grep -v "efflux" | grep "aminoglycoside" | cut -f6 | grep -v "bla" | sort |\
			uniq -c | sed -e 's/^[ \\t]*//'| tr -d "'" | tr " " ";" | sed -e 's/\$/;aminoglycoside-resistance/') 
		printf "\${aminoData}\\n" >> "${name}"_"${abricate_db}".csv
		
		# efflux
		effluxData=\$(tail -n+2 ${dir} | grep -v "tetracycline" | grep "efflux" | cut -f6 | grep -v "bla" | sort |\
			uniq -c | sed -e 's/^[ \\t]*//'| tr -d "'" | tr " " ";" | sed -e 's/\$/;efflux-system/') 
		printf "\${effluxData}\\n" >> "${name}"_"${abricate_db}".csv
		
		# quinolones
		quinoData=\$(tail -n+2 ${dir} |  grep -v "efflux" | grep "quinolone" | cut -f6 | grep -v "bla" | sort |\
			uniq -c | sed -e 's/^[ \\t]*//'| tr -d "'" | tr " " ";" | sed -e 's/\$/;quinolone-resistance/') 
		printf "\${quinoData}\\n" >> "${name}"_"${abricate_db}".csv
		
		# other
		otherData=\$(tail -n+2 ${dir} |  grep -v "efflux" | grep -v "tetracycline" | grep -v "aminoglycoside" | grep -v "quinolone" |\
			cut -f6 | grep -vE "bla[A-Z]|lactamase" |  sort |\
			uniq -c | sed -e 's/^[ \\t]*//'| tr -d "'" | tr " " ";" | sed -e 's/\$/;other-resistance-genes/') 
		printf "\${otherData}\\n" >> "${name}"_"${abricate_db}".csv
		"""
}