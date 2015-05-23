#!/usr/bin/perl
# Script: parsemol2.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.30.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: parsemol2.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $mol, "<", $input) or die "Can't open $input: $!\n";
my $lig_count = 0;
my ($outfile,$lig); # file and directory names for new ligands
my %zinc_map;

while(my $line = <$mol>)
{
  chomp $line;
  if($line eq "@<TRIPOS>MOLECULE") # record-delimiting line
  {
    $lig_count++;
    if($lig_count > 1)
    {
      close(OUT);
      system("mkdir $lig");
      system("mv $outfile $lig");
    }
    $lig = sprintf("LIG_%03d",$lig_count);
    $outfile = "$lig.mol2";
    open(OUT,">",$outfile);
  }
  if($line =~ /^ZINC/)
  {
    my $ZID = $line;
    $ZID =~ s/^ZINC//;
    $zinc_map{$lig} = $ZID;
  }
  print $outfile,"\n" if $verb;
  print OUT $line,"\n";
}
close($mol);
system("mkdir $lig");
system("mv $outfile $lig");

open(my $map, ">", "ZINC_IDs");
print $map "#LIG\tZINC ID\n";
foreach my $key (sort keys %zinc_map)
{
  print $map "$key\t$zinc_map{$key}\n";
}
close($map);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
