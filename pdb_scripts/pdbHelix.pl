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
use lib '/home/sahrendt0/Scripts/pdb_scripts/';
use PDBAnalysis;

#####-----Global Variables-----#####
my ($input,$list);
my $dir = ".";
my $chain = "A"; 	# default chain of helices
my ($help,$verb);
my ($start,$stop);
my $filename;
my @infiles;
GetOptions ('i|input=s' => \$input,
            'l|list=s'  => \$list,
            'h|help'    => \$help,
            'v|verbose' => \$verb,
            'd|dir=s'   => \$dir,
            'c|chain=s' => \$chain);
my $usage = "Usage: pbdHelix.pl [-d] -i input |-l list\n";
die $usage if $help;
die $usage if (!$input and !$list);


#####-----Main-----#####
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
  print $file,"\n" if ($verb);
  $PDB->Parse;
  $filename = (split(/\//,$file))[-1];
  $filename = (split(/\./,$filename))[0];
  open(OUT,">$filename\_$chain\_helices.pdb");
  my @helices = getHelices($PDB);  # get a list of regions based on the HELIX rows
  chomp @helices;
#  print @helices if ($verb);
  my @write_out;
  foreach my $hel (@helices)
  {
    chomp $hel;
    print "$hel\n" if ($verb);
    my ($init,$serNum,$helixID,$initResName,$initChainID,$initSeqNum,$initICode,$endResName,$endChainID,$endSeqNum,$endICode,$helixClass,$comment,$length) = parseHelix($hel);
    my @helixData = parseHelix($hel);
    print join("--",@helixData),"\n";
    next if($initChainID ne $chain);  # Only get Chain A
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
