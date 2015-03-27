#!/usr/bin/perl
# Script: renameChainA.pl
# Description: Changes chain X to chain A for homology models 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.05.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts/pdb_scripts';
use PDBAnalysis;

#####-----Global Variables-----#####
my $input;
my $all;
my @pdbs;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'a|all'    => \$all,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: renameChainA.pl -i input\nChanges chain X to chain A for homology models\n";
die $usage if $help;
die "No input.\n$usage" if (!$input && !$all);

#####-----Main-----#####
if($all)
{
  opendir(DIR,".");
  @pdbs = grep { /\.pdb$/ } readdir(DIR);
  closedir(DIR);
}
else
{
  push @pdbs,$input;
}

foreach my $pdb_file (@pdbs)
{
  print $pdb_file,"\n";
  my @pdb_name = split(/\./,$pdb_file);
  pop @pdb_name;
  my $pdb_out = join("\.",@pdb_name);
  print $pdb_out,"\n";
  my $PDB = ParsePDB->new(FileName => $pdb_file,
                          noHETATM => 1,
                          noANISIG => 1);
  $PDB->Parse;
  $PDB->RenumberChains(ChainStart => 'A');
  $PDB->Write(FileName => "$pdb_out\.clean.pdb"); 
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
