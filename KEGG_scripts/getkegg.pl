#!/usr/bin/perl
# Script: getkegg.pl
# Description: Parses a keggfile and downloads the genes 
# Author: Steven Ahrendt
#################################

use warnings;
use strict;
use Getopt::Long;

my $help;
my $input;

GetOptions ("i|input=s" => \$input,
            "h|help"   => \$help);

my $usage = "Usage: getkegg.pl -i kegg_genelist\n";
die $usage if($help);
die "No input file: $!\n$usage" if (!$input);

open(IN,$input) || die "Can't open $input\n";
foreach my $line (<IN>)
{
  chomp $line;
  print `wget -O $line.faa http://rest.kegg.jp/get/$line/aaseq`;
}
close(IN);
