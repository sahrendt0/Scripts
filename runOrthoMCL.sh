#######
# Manual tasks:
#  
module load orthoMCL/2.0.3
module load ncbi-blast

blast_input="goodProteins.fasta"
config="/rhome/sahrendt/bigdata/Data/orthomcl.config"

makeblastdb -dbtype prot -in "$blast_input" 
blastall -p blastp -a 4 -m 8 -d "$blast_input" -i "$blast_input" -o m8blast.output
orthomclBlastParser m8blast.output compliantFasta >> similarSequences.txt
orthomclLoadBlast $config similarSequences.txt
orthomclPairs $config orthomcl_pairs.log cleanup=no
orthomclDumpPairsFiles $config
mcl mclInput --abc -I 1.5 -o mclOutput
orthomclMclToGroups "$blast_input" 1000 < mclOutput > groups.txt
