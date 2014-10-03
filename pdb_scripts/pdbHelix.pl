#!/usr/bin/perl
# Script pdbHelix.pl
# Description: Automatically finds and extracts helical regions from pdbfiles
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.7.13
#         v.1.0	: 
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts/pdb_scripts';
use PDBAnalysis;

#####-----Global Variables-----#####
my ($input,$list);
my $dir = ".";
my ($help,$verb);
my ($start,$stop);
my $filename;
my @infiles;
GetOptions ('i|input=s' => \$input,
            'l|list=s'  => \$list,
            'h|help'    => \$help,
            'v|verbose' => \$verb,
            'd|dir=s'   => \$dir);
my $usage = "Usage: pbdHelix.pl -d -i input |-l list\n";
die $usage if $help;
die $usage if (!$input and !$list);

if($list)
{
  $list = "$dir/$list";
  open(LIST,"<$list") or die "Can't open $list: $!\n";
  @infiles = <LIST>;
  close(LIST);
  chomp @infiles;
}
else
{
  push (@infiles, $input);
}

foreach my $file (@infiles)
{
  my $PDB = ParsePDB->new(FileName => "$dir/$file",
                          NoHETATM => 1,  # filter HETATM lines
                          NoANISIG => 1);   # filter SIGATM, SIGUIJ, ANISOU lines
  print $file,"\n";
  $PDB->Parse;
  $filename = (split(/\//,$file))[-1];
  $filename = (split(/\./,$filename))[0];
  open(OUT,">$filename\_A\_helices.pdb");
  my @helices = getHelices($PDB);  # get a list of regions based on the HELIX rows
  chomp @helices;
  my @write_out;
  foreach my $hel (@helices)
  {
    chomp $hel;
    my ($init,$serNum,$helixID,$initResName,$initChainID,$initSeqNum,$initICode,$endResName,$endChainID,$endSeqNum,$endICode,$helixClass,$comment,$length) = parseHelix($hel);
    next if($initChainID ne 'A');  # Only get Chain A
    print OUT $hel,"\n";
    $initSeqNum =~ s/^\s*(\d+)\s*/$1/;
    $endSeqNum =~ s/^\s*(\d+)\s*/$1/;
    push (@write_out, extractFrag($PDB,$initSeqNum,$endSeqNum));
  }
  print OUT @write_out,"\n";
  close(OUT);
}

warn "Done.\n";
exit(0);
