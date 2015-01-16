t_coffee -other_pg seq_reformat -in $1 -output code_name > code_file
t_coffee -other_pg seq_reformat -code code_file -in $1 > coded_file
mafft --auto coded_file > coded_file.mafft
