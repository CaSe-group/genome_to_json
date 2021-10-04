process collect_fasta {
    label 'ubuntu'
    input:
        path(input_path)
    output:
        path("**.fasta"), includeInputs: true   //take all fasta-files, also from sub-dirs & from input-channel
    script:
        """
        case "${input_path}" in
            *.fasta)
                ;;
            *.fa)
                cp ${input_path} \$(basename -s .fa ${input_path}).fasta
                ;;
            *.fna)
                cp ${input_path} \$(basename -s .fna ${input_path}).fasta
                ;;
            *.gz)
                zcat ${input_path} >> \$(echo "${input_path}" | sed "s/.gz//").fasta
                ;;
            *)
                for FILE in \$(find -L ${input_path} -name "*.fasta*"); do              #for loop over all ".fasta*"-files in the path
                    case \$FILE in
                        *.gz)
                            zcat \$FILE >> \$PWD/\$(echo "\$FILE" | rev | cut -f 1 -d '/' | rev | sed "s/.gz//");   #zcat into file name without ".gz"-extension
                    esac
                done
        esac
        """
    stub:
        """
        touch stub.fasta
        """
}