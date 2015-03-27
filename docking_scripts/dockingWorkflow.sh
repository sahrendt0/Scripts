###############################################
# Ligand and receptor datasets
#  Ligands were obtained as an .sdf file from ChemMine (cite) after a similarity search at 90% using various isomers of retinal as templates: 11-cis-retinal (A1), 3,4-dihydroretinal (A2), 3-hydroxyretinal (A3), 4-hydroxyretinal (A4), all-trans-retinal.
#   Receptors were obtained from the PDB (cite) where applicable or modeled using Modeller or iTasser as described previously.
###########################
# Noncovalent – 100 GA runs, 100 ligands
# Covalent – 100 GA runs, 100 ligands, bound to specific lysine residue (where applicable)
#########################################
# 2.27.15 |
# --------+
# 100 ligands at 90% similarity to 11-cis-retinal
#  - SMILES: CC1=C(C(CCC1)(C)C)C=CC(=CC=CC(=CC=O)C)C
#  - ChemMine -> "fingerprint search"
#  - manually include A2, A3, A4	: 103 ligands total => "ligandIDs"
#################
# Mnnual tasks: 
#   set up pdbqt format
# Scripts used & workflow
#   - use individual directories for each receptor
########
# $1 = receptor
# $2 = critical receptor atom number
############################################
# Copy receptor to current dir under new name
#ln -s ../1U19_helices.pdb Btau1U19.pdb
# Split the master sdf file to get all chemical files
parseMultiSDF.R A1_sim90.sdf

# Clean up the resulting filenames
rename 's/\_\d{3}\./\./' *.sdf

# Move the ligands to individual directories and set up the symlinks
multidock.pl

# Set up the shell scripts for multiple docking
## Need to merge batch_docking and covalent docking...set up some subroutines
#batch_docking.pl
#docking_workflow_master.pl -r $1 -a $2 
