#!/usr/bin/perl
# Script: fasta2taxonomy.pk
# Description: Generates a taxonomy file from species in a Fasta description line 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.13.2014
##################################
use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use SeqAnalysis;
use Getopt::Long;
use Data::Dumper;
#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: fasta2taxonomy.pk -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $hash_ref = getTaxonomy($input);

print Dumper $hash_ref;
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
