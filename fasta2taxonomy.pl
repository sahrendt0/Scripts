#!/usr/bin/perl
# Script: fasta2taxonomy.pk
# Description: Generates a taxonomy file from species in a Fasta description line 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.13.2014
##################################
use warnings;
use strict;
use Getopt::Long;

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

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####