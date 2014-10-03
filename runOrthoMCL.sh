module load orthoMCL
module load ncbi-blast

blast_input=$1

makeblastdb -dbtype prot -in "$blast_input" 
blastall -p blastp -a 4 -m 8 -d "$blast_input" -i "$blast_input" -o m8blast.output
orthomclBlastParser m8blast.output compliantFasta >> similarSequences.txt
orthomclLoadBlast orthomcl.config similarSequences.txt
orthomclPairs orthomcl.config orthomcl_pairs.log cleanup=no
orthomclDumpPairsFiles orthomcl.config
mcl mclInput --abc -I 1.5 -o mclOutput
orthomclMclToGroups "$blast_input" 1000 < mclOutput > groups.txt
