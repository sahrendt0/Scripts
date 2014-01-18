#!/usr/bin/perl
# Script: fastaresize.pl
# Description: Rewrites a fasta file to be of a new width
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 7.8.13
#         - added option to replace input file
#         - cleaned up; added option for single line
#             - defaults to single line if no value provided for -w(idth)
####################################
# Usage: fastaresize.pl [-r] -i fastafile -w new_width
####################################

use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

my $replace;
my $input;
my $width;
my $help;

GetOptions ('w|width=i'  => \$width,
            'i|input=s'  => \$input,
            'r|replace' => \$replace,
            'h|help'     => \$help);

my $usage = "Usage: fastaresize.pl [-r] -i fastafile -w new_width\n";
die $usage if $help;
die "No input.\n$usage" if (!$usage);

#####-----Main-----#####
my $outfile = "$input\.$width";

my $in = Bio::SeqIO->new(-file   => $input, 
                         -format => "fasta");

my $out = Bio::SeqIO->new(-file   => ">$outfile", 
                          -format => "fasta", 
                          -width  => $width);

while(my $seq = $in->next_seq())
{
  $out->write_seq($seq);
}
if($replace)
{
  print `mv $outfile $input`;
}

warn "Done.\n";
exit(0);
