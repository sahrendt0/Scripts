t_coffee -other_pg seq_reformat -in $1 -output code_name > code_file
t_coffee -other_pg seq_reformat -code code_file -in $1 > coded_file
t_coffee -in coded_file -n_core=4 -run_name=IN -evaluate_mode=t_coffee_slow -output=score_ascii fasta_aln phylip -case=upper -outorder=input 
