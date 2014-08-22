#!/usr/bin/perl
# Script: gffParse.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 07.09.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Bio::Tools::GFF;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: gffParse.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
# specify input via -fh or -file
my $gffio = Bio::Tools::GFF->new(-file => $input, 
                                 -gff_version => 2);
# loop over the input stream
while(my $feature = $gffio->next_feature()) 
{
  print $feature->primary_tag(),"\n";
}
$gffio->close();
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
