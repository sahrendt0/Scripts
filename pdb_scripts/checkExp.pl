#!/usr/bin/perl
# Script checkExp.pl
# Description: Grabs the experiment line and checks method (xray, nmr, etc)
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.7.13
##################################
use warnings;
use strict;
use Getopt::Long;
use PDBAnalysis;
use ParsePDB;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $all;
my $dir = ".";
my @files;

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb,
            'a|all'    => \$all,
            'd|dir=s'  => \$dir);
my $usage = "Usage: checkExp.pl -a | -i input\n";
die $usage if $help;

if($all)
{
  opendir(DIR,$dir);
  @files = grep { /\.pdb/ } readdir(DIR);
  close(DIR);
}
else
{
  push(@files,$input);
}

foreach my $file (@files)
{
  my $PDB = ParsePDB->new(FileName => "$dir/$file",
                          NoHETATM => 1,  # filter HETATM lines
                          NoANISIG => 1);   # filter SIGATM, SIGUIJ, ANISOU lines
  #print $file,"\t";
  $PDB->Parse;
  my @exp = getExp($PDB);
  if($exp[0] =~ m/nmr/i)
  {
    print $file,"\t";
    print @exp;
  }
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
