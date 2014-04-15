#!/usr/bin/perl
# Script: getPFAM.pl
# Description: Gets all PFAM IDs associated with a gene ID for a given organism
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.04.2014
##################################
use warnings;
use strict;
use lib '/rhome/sahrendt/Scripts';
use Getopt::Long;
use BCModules;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my (%pfam,$pfamFile,$spec);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getPFAM.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
$spec = (split(/\./,$input))[0];
$pfamFile = "$spec\_pfam_to_genes.txt";
%pfam = indexPFAM($pfamFile);
open(my $fh, "<", $input) or die "Can't open $input: $!\n";
while(my $line = <$fh>)
{
  chomp $line;
  print $line,"\t";
  my $id = (split(/\|/,$line))[1];
  $id =~ s/T\d$//;
  if(exists $pfam{$id})
  {
    for(my $i=0;$i < scalar @{$pfam{$id}{PFAM_ACC}}; $i++)
    {
      print @{$pfam{$id}{PFAM_ACC}}[$i],";";
    }
  }
  print "\n";
}
close($fh);
#print Dumper \%pfam;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
