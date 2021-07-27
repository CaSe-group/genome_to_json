#!/bin/bash -ue
abricate GCA_000534275.1.fasta --nopath --quiet --mincov 80 --db ncbi >> "GCA_000534275"_abricate_ncbi.tsv
abricate GCA_000534275.1.fasta --nopath --quiet --mincov 80 --db card >> "GCA_000534275"_abricate_card.tsv
abricate GCA_000534275.1.fasta --nopath --quiet --mincov 80 --db vfdb >> "GCA_000534275"_abricate_vfdb.tsv
abricate GCA_000534275.1.fasta --nopath --quiet --mincov 80 --db ecoh >> "GCA_000534275"_abricate_ecoh.tsv
