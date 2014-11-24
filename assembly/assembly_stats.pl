#!/usr/bin/perl
# Script: assembly_stats.pl
# Description: Uses seqlen.pl and calcN50.pl to give some quick stats about an assembly
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.19.2014
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
my $usage = "Usage: assembly_stats.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
system("seqlen.pl -i $input");
system("calcN50.pl -v -i $input");
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
