#!/usr/bin/perl
# Script: renameChainA.pl
# Description: Changes chain X to chain A for homology models 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.07.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts/pdb_scripts';
use PDBAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: renameChainA.pl -i input\nChanges chain X to chain A for homology models\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $PDB = ParsePDB->new(FileName => $input,
                        noHETATM => 1,
                        noANISIG => 1);

$PDB->Parse;
$PDB->RenumberChains();
$PDB->Write(FileName => "file.pdb"); 
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
