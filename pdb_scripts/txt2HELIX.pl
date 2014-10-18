#!/usr/bin/perl
# Script: txt2HELIX.pl
# Description: Takes a master description file and makes a HELIX line in pdb file; experimental 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.03.2014
##################################
# file header:
#  Bovine  Squid   Bd      Sp      Am      Mel	Description     ColorID
#########################################################################
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts/pdb_scripts';
use PDBAnalysis;
use ParsePDB;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %helices;
my $mapfile = "structureMap"; # file with ID-to-PDBfile map, tsv
my %structures; # ID-to-PDBfile mapping of structures/models

## Known
my $RHOD_RESIDUES = "/rhome/sahrendt/bigdata/Chytrid_Rhodopsin/DataReadme/rhodopsin_residues";

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: txt2HELIX.pl -i input\nTakes a master description file and makes a HELIX line in pdb file; experimental\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
## Get ID to file map
structuresInit();

open(my $rh, "<", $RHOD_RESIDUES) or die "Can't open $RHOD_RESIDUES: $!\n";
my $lc = 0;  ## line counter
while(my $line = <$rh>)
{
  next if ($line =~ /^#/);
  next if ($line =~ /B\d/);
  last if ($line =~ /\/\//);
  chomp $line;
  if($lc > 0)
  {
    print $line,"\n";
    my($bov,$sqd,$bd,$sp,$am,$mel,$desc,$color) = split(/\s+/,$line);
    $helices{'Bov'}{$desc} = $bov;	## Stored as period-delimited range: start.stop
    $helices{'Sqd'}{$desc} = $sqd;
    $helices{'Bd'}{$desc} = $bd;
    $helices{'Sp'}{$desc} = $sp;
    $helices{'Am'}{$desc} = $am;
    $helices{'Mel'}{$desc} = $mel;	# Melatonin
  }
  $lc++;
}
close($rh);

print Dumper \%helices;
foreach my $key (sort keys %helices)
{
  my $PDB = ParsePDB->new(FileName => "./$structures{$key}",
                          NoHETATM => 1,
                          NoANISIG => 1);
  $PDB->Parse;
  open(my $of,">","$key.out");
  foreach my $region (sort keys %{$helices{$key}})
  {
    next if ($region !~ /H/);
    my($start,$stop) = split(/\./,$helices{$key}{$region});
    my $num = (split(//,$region))[1];
    print $of "HELIX ";                  # pos 1  -  6
    print $of " ";			 # pos 7 (empty space)
    printf $of "%-3s",$num;              # pos 8  - 10
    print $of " ";                       # pos 11 (empty space)
    print $of "$region ";                # pos 12 - 14
    print $of " ";                       # pos 15 (empty space)
    print $of $PDB->GetResidueLabel(Residue => $start); # pos 16 - 18
    print $of " X ";                     # pos 19 - 21
    printf $of "%4s",$start;             # pos 22 - 25
    print $of " ";                       # pos 26 (insertion code)
    print $of " ";                       # pos 27 (empty space)
    print $of $PDB->GetResidueLabel(Residue => $stop);  # pos 28 - 30
    print $of " X ";                     # pos 31 - 33
    printf $of "%4s",$stop;              # pos 34 - 37
    print $of " ";                       # pos 38 (insertion code)
    print $of "  ";                      # pos 39 - 40 (helix class)
    print $of (' ' x 30);                # pos 41 - 70
    print $of " ";                       # pos 71 (empty space)
    printf $of "%5s",(($stop-$start)+1); # pos 72 - 76 
    print $of "\n";
  }
  close($of);
  system("cat $structures{$key} >> $key.out");
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub structuresInit {
  open(my $fh, "<", $mapfile) or die "Can't open $mapfile: $!\n";
  while(my $line = <$fh>) 
  {
    chomp $line;
    my($key,$val) = split(/\t/,$line);
    $structures{$key} = $val;
  }
  close($fh);
}
