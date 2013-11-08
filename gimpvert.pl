#!/usr/bin/perl
# Script: gimpvert.pl
# Description: Converts gel-imager .tif images to .png files; opens in Gimp for optional editing
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.7.13
####################################
# Usage: gimpvert.pl imagefile
####################################

use strict;
use warnings;
use Getopt::Long;

my $infile;# = $ARGV[0];
my $help=0;
GetOptions("i|input=s" => \$infile,
           "h|help+"   => \$help);

if($help)
{
  print "Usage: gimpvert.pl -i imagefile\n";
  exit;
}

my @f = split(/\./,$infile);
pop(@f); #remove file extension
my $outfile = join(".",@f,"png");

print `convert $infile $outfile`;
print `gimp $outfile`;
