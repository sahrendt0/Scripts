#!/usr/bin/perl
# Script: calcN50.pl
# Description: Test to calculate N50 value 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.16.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: calcN50.pl -i input\nTest to calculate N50 value\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

print N50($input,$verb)," : N50\n";

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
