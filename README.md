BCModules.pm. . . . . . Biocluster specific sequence analysis modules<br>
FM_ZygoAnalysis.pl. . . Specific script for analysis of Zygomycete run <br>
IPR_reorder.pl. . . . . Used in MG_HMM workflow <br>
SeqAnalysis.pm. . . . . Perl module containing often-used subroutines for sequence processing<br>
bio3d.R . . . . . . . . Loads Bio3D module and runs through steps to generate PCA plot<br>
blast2krona.pl. . . . . Takes BLAST results and creates a Krona data file <br>
bp_sreformat.pl . . . . <br>
bp_ssearchparse.pl. . . Parses all ssearch files in the given directory; Gathers counts and sequences.<br>
cbind.pl. . . . . . . . Like cbind() in R <br>
dephylip_tree.pl. . . . Dephylips Newick tree files<br>
fasta2go.pl . . . . . . Joins geneIDs to GO terms using previously established DBs <br>
fasta2hmm.pl. . . . . . Pipeline for converting unaligned fasta files to hmm files<br>
fasta2taxonomy.pl . . . Generates a taxonomy file from species in a Fasta description line <br>
fastaClean.pl . . . . . Cleans up fasta descriptions (Not for general use; highly specific) <br>
fastaresize.pl. . . . . Rewrites a fasta file to be of a new width<br>
gbk2pep.pl. . . . . . . Parses out translated regions from a genbank file<br>
getPFAM.pl. . . . . . . Gets all PFAM IDs associated with a gene ID for a given organism<br>
getSingleTax.pl . . . . Single use to get full taxonomy of a species <br>
getTopHit.pl. . . . . . Gets the top hit from an m8 formatted blast results file <br>
getaccnos.pl. . . . . . Gets names of all sequences in a .fasta file (this is done using seqcount.pl as well)<br>
getkegg.pl. . . . . . . Parses a keggfile and downloads the genes <br>
getscripts.pl . . . . . Produces README.md containing all of the custom scripts in ~/scripts<br>
getseqfromfile.pl . . . Provide a sequence ID and a fasta flatfile (database) and the script will return the fasta-formatted sequence<br>
getseqs.pl. . . . . . . Retrieve sequences from GenBank based accession numbers found in the input file<br>
gimpvert.pl . . . . . . Converts gel-imager .tif images to .png files; opens in Gimp for optional editing<br>
hashPFAM.pl . . . . . . Analyse flagellar patterns <br>
hmmCount.pl . . . . . . General script to get counts from HMM results file <br>
hmm_run.pl. . . . . . . Generates a shell script to run batch searches using either hmmsearch or hmmscan<br>
hmmparse.pl . . . . . . Parses an HMM result file, scan or search<br>
kegg.pl . . . . . . . . Queries the KEGG db to collect genes in a given pathway<br>
mkpdf.R . . . . . . . . R script to use Sweave to convert LaTeX file to pdf and display<br>
mkpl.pl . . . . . . . . Sets up perl skeleton script<br>
mkpm.pl . . . . . . . . Sets up a perl module template with comments and standard info <br>
parseByTax.pl . . . . . Trims an "out_table" file in accordance with a specific set of organisms <br>
patternAnalysis.pl. . . A script to analyze patterns in the flagella (gain/loss) search<br>
pf2g.pl . . . . . . . . Takes a list of pfam IDs and maps them to go terms<br>
print_all.R . . . . . . Loads Bio3D module and plots PCA using a variety of pre-defined color schemes<br>
processHits.pl. . . . . Pulls out specific proteins from this Flagellar SSEARCH run <br>
process_kegg.pl . . . . Process a KEGG record file<br>
qiime_workflow.pl . . . Generate shell scripts for processing qiime Amend2009 files w/ UNITE db <br>
qiime_workflow2.pl. . . Generate shell scripts for processing qiime Amazon_air files w/ UNITE db <br>
seqlen.pl . . . . . . . Extracts sequence lengths from a fasta file<br>
showPool.pl . . . . . . Takes pool input and highlights residues in Pymol<br>
spc2us.pl . . . . . . . renamer script used for replacing spaces w/ underscores in filenames<br>
ssearch_run.pl. . . . . Generates batch shell script for ssearches<br>
ssearchrank.pl. . . . . Searches many FASTA search result files to get a better scoring match for a particular transcript<br>
