#!/usr/bin/perl -w
# Script: getchainA.pl
# Description: Extracts the 'A' chain from the pdb files in the current directory
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 4.15.11
#         v1.0  : uses ParsePDB (http://comp.chem.nottingham.ac.uk/parsepdb/)
#               : could potentially implement a fasta-writing portion using BioPerl
#	  v1.5  : added arguments
##########################################################
# Default: get Chain A for all .pdb files in current directory
# Optional: -i PDB_ID argument gets Chain A for the specified PDB file
#######################################################
# Usage: getchainA.pl           #
#     or                        #
# Usage: getchainA.pl -i PDB_ID #
#################################

use strict;
use lib '/rhome/sahrendt/Scripts/pdb_scripts';
use ParsePDB;
use Getopt::Long;

my $input;
my @pdbs;
my ($all,$help,$verb);

GetOptions ("i|input=s" => \$input,
            "a|all" => \$all,
            "h|hel+" => \$help,
            "v|verbose" => \$verb);

my $usage = "Usage: getchainA.pl [-a|-i pdbfile]\n";
die $usage if ($help);
die $usage if (!$input && !$all);

## If -i is provided, use PDB file provided as argument
## Otherwise, use all .pdb files in the current directory
if ($all) 
{
  opendir(DIR,".");
  @pdbs = grep { /\.pdb$/ } readdir(DIR);
  closedir(DIR);
}
else
{
  push(@pdbs,$input);
}

foreach my $filename (@pdbs)
{
  print $filename;
  my @f = split(/\./,$filename);
  my $id = $f[-2];
  print ": $f[-2]";
  my $PDB = ParsePDB->new(
    FileName => $filename, 
    NoHETATM => 1,  # filter HETATM lines
    NoANISIG => 1   # filter SIGATM, SIGUIJ, ANISOU lines
);
  $PDB->Parse;
  my @chains = $PDB->IdentifyChainLabels(Model => 0);
  #print $PDB->IdentifyResidueLabels(Chain => 0, OneLetterCode => 1),"\n";
  foreach my $chain (@chains)
  {
    open(OUT,">","$id\_$chain");
    print OUT $PDB->Get(Model => 0,ChainLabel => $chain),"\n";
    close(OUT);
  }
}

