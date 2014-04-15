#!/usr/bin/perl
# Script: hmmCount.pl
# Description: General script to get counts from HMM results file 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.31.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use SeqAnalysis;
use Data::Dumper;
#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: hmmCount.pl -i input\nWrites to file\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my %counts = hmmParse($input);

open(OUT,">$input\.counts");
foreach my $key (sort keys %counts)
{
  print OUT "$key\t$counts{$key}\n";
}
close(OUT);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
