#!/usr/bin/perl
# Script: txt2HELIX.pl
# Description: Takes a master description file and makes a HELIX line in pdb file; experimental 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.03.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $RHOD_RESIDUES = "rhodopsin_residues";

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: txt2HELIX.pl -i input\nTakes a master description file and makes a HELIX line in pdb file; experimental\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
