process collect_fasta {
    label 'ubuntu'
    input:
        path(input_path)
    output:
        path("**.fasta"), includeInputs: true   //take all fasta-files, also from sub-dirs & from input-channel
    script:
        """
        if [[ ${input_path} == *".fasta" ]] | [[ ${input_path} == *".fasta.gz" ]]; then #check if input is single "fasta" or "fasta.gz"-file
            if [[ ${input_path} == *".gz" ]]; then                                      #if input is single "fasta.gz"-file
                zcat ${input_path} >> \$(echo "${input_path}" | sed "s/.gz//");         #zcat into input-file name without ".gz"-extension
            fi;
        else                                                                            #directory-path is given
            for FILE in \$(find -L ${input_path} -name "*.fasta*"); do                  #for loop over all ".fasta*"-files in the path
                if [[ \$FILE == *".gz" ]]; then                                         #test each file if it is a ".fasta.gz"
                    zcat \$FILE >> \$PWD/\$(echo "\$FILE" | rev | cut -f 1 -d '/' | rev | sed "s/.gz//");   #zcat into file name without ".gz"-extension
                fi;
            done;
        fi
        """
    stub:
        """
        touch stub.fasta
        """
}