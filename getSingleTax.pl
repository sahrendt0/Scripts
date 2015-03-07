#!/usr/bin/perl
# Script: getSingleTax.pl
# Description: Single use to get full taxonomy of a species 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.04.2014
##################################
use warnings;
use strict;
use lib '/rhome/sahrendt/Scripts';
use Getopt::Long;
use SeqAnalysis;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $hash_ref;
my $db_form = "flatfile";
my @ranks = qw(Kingdom Phylum Class Order Family Genus Species); # Standard 7 taxonomic rankings

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getSingleTax.pl -i input\nOutput to STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $NCBI_TAX = initNCBI($db_form);
open(my $fh,"<",$input);
while(my $line = <$fh>)
{
  if($line =~ /^#/)
  {
    print $line;
    next;
  }
  chomp $line;
  my($abb,$c1,$c2,$spec,$ver,$web) = split(/\t/,$line);
  my @data = split(/ /,$spec);
  my $newSpec = join(" ",$data[0],$data[1]);
  #$hash_ref->{$input} = getTaxonomy($NCBI_TAX,$input,$db_form,$verb);
  #print "\"$spec\": ".getTaxIDbySpecies($NCBI_TAX,$spec)."\n";
  my $taxID = getTaxIDbySpecies($NCBI_TAX,$newSpec);
  print join("\t",$abb,$c1,$c2,$taxID,$spec,$ver,$web),"\n";
}
close($fh);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
