#!/usr/bin/perl
# Script: txt2HELIX.pl
# Description: Takes a master description file and makes a HELIX line in pdb file; experimental 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.03.2014
##################################
# residue file header:
#  ColorID	Description	@structureIDs
##############################################
# "structureMap" contains the IDs in the residue file mapped to the actual structure filenames
###################################################
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use lib "/*home/sahrendt/Scripts/pdb_scripts";
use PDBAnalysis;
use ParsePDB;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %hash_data;
my $mapfile = "structureMap"; # file with ID-to-PDBfile map, tsv
my %structures; # ID-to-PDBfile mapping of structures/models

## Known
#my $RHOD_RESIDUES = "/rhome/sahrendt/bigdata/Chytrid_Rhodopsin/DataReadme/rhodopsin_residues";
my $RHOD_RESIDUES = "ClatOpsinHelices";

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: txt2HELIX.pl \nTakes a master description file and makes a HELIX line in pdb file; experimental\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
## Get ID to file map
structuresInit();

open(my $rh, "<", $RHOD_RESIDUES) or die "Can't open $RHOD_RESIDUES: $!\n";
my $lc = 0;  ## line counter
my ($section,@keys);
while(my $line = <$rh>)
{
  next if ($line =~ /\/\//);
  chomp $line;
  if($line =~ /^#/)
  {
    $section = $line;
    $section =~ s/^#//;
  }
  else
  {
    my ($reg,$col,@data) = split(/\t/,$line);
    if($reg eq "Description")
    {
      @keys = @data;
    #  shift @keys; # remove "Description"
    #  shift @keys; # remove "colorID"
    }
    else
    {
      #my @coords = @data;
      for(my $i=0;$i<scalar(@data);$i++)
      {
        $hash_data{$section}{$keys[$i]}{$reg}{Color}= $col;
        $hash_data{$section}{$keys[$i]}{$reg}{Span}= $data[$i];
      }
    }
    $lc++;
  }
}
close($rh);

#print Dumper \%hash_data;
prependHELIX(\%hash_data,\%structures);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub prependHELIX {
  my %helices = %{shift @_};
  my %structures = %{shift @_};

  foreach my $key (sort keys %{$helices{Helices}})
  {
    my $PDB = ParsePDB->new(FileName => "./$structures{$key}",
                            NoHETATM => 1,
                            NoANISIG => 1);
    $PDB->Parse;
    open(my $of,">","$structures{$key}.out");
    foreach my $region (sort keys %{$helices{Helices}{$key}})
    {
      next if ($region !~ /H/);
      my($start,$stop) = split(/\./,$helices{Helices}{$key}{$region}{Span});
      my $num = (split(//,$region))[1];
      print $of "HELIX ";                  # pos 1  -  6
      print $of " ";			 # pos 7 (empty space)
      printf $of "%-3s",$num;              # pos 8  - 10
      print $of " ";                       # pos 11 (empty space)
      print $of "$region ";                # pos 12 - 14
      print $of " ";                       # pos 15 (empty space)
      print $of $PDB->GetResidueLabel(Residue => $start); # pos 16 - 18
      print $of " A ";                     # pos 19 - 21
      printf $of "%4s",$start;             # pos 22 - 25
      print $of " ";                       # pos 26 (insertion code)
      print $of " ";                       # pos 27 (empty space)
      print $of $PDB->GetResidueLabel(Residue => $stop);  # pos 28 - 30
      print $of " A ";                     # pos 31 - 33
      printf $of "%4s",$stop;              # pos 34 - 37
      print $of " ";                       # pos 38 (insertion code)
      print $of "  ";                      # pos 39 - 40 (helix class)
      print $of (' ' x 30);                # pos 41 - 70
      print $of " ";                       # pos 71 (empty space)
      printf $of "%5s",(($stop-$start)+1); # pos 72 - 76 
      print $of "\n";
    }
    close($of);
    system("cat $structures{$key} >> $structures{$key}.out");
  }
}

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
