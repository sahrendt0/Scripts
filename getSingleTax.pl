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
$hash_ref->{$input} = getTaxonomy($input,$db_form,$verb);
if($hash_ref->{$input}{"kingdom"} eq "NULL")
{
  print Dumper $hash_ref if $verb;
}
printTaxonomy($hash_ref,\@ranks,$input);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
