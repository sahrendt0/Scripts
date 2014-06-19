#!/usr/bin/perl
# Script: replot.pl
# Description: Changes default sampleID names to countries 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.30.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my ($input,$map);
my ($help,$verb);
my %map_hash;

GetOptions ('i|input=s' => \$input,
            'm|map=s'   => \$map,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: replot.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $mapH, "<", $map);
while (my $line = <$mapH>)
{
  chomp $line;
  next if($line =~ /^#/);
  my ($key,$val) = split(/\t/,$line);
  my @tmp = split(/\:/,$val);
  $val = $tmp[1];
  $map_hash{$key} = $val;
}
close($mapH);

open(my $inH, "<", $input) or die "Can't open $input: $!\n";
while(my $line = <$inH>)
{
  chomp $line;
  if($line =~ /^Taxon/)
  {
    my @data = split(/\t/,$line);
    foreach my $item (@data)
    {
      my $country;
      if(!$map)
      {
        my @tmp = split(/\_/,$item);
        $country = $tmp[0];
      }
      else
      {
        if($item eq "Taxon")
        {
          $country = "Taxon";
        }
        else
        {
          $country = $map_hash{$item};
        }
      }
      print $country,"\t";
    }
    print "\n";
  }
  else
  {
    print $line,"\n";
  }
}
close($inH);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
