#!/usr/bin/perl
# Script: process_kegg.pl
# Description: Process a KEGG record file
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 9.17.13
#####################
# Currently only focus on extracting GENES records from a KO entry file
# *** THIS WOULD BE GOOD PRACTICE TO LEARN ABOUT OBJECT-ORIENTED PROGRAMMING IN PERL ***
# *** WRITE A BIOPERL PARSER FOR KEGG FILES: DOES THIS EXIST ALREADY? ***
#####################
# Usage: process_kegg.pl -i inputfile
#####################

use strict;
use warnings;
use Getopt::Long;

my $help;
my $input;

GetOptions("h|help"   => \$help,
           "i|input=s" => \$input);

my $usage = "Usage: process_kegg.pl -i inputfile\n";
die $usage if($help);
die "No input file: $!\n$usage" if (!$input);

my %genes;
open(IN,"<$input") || die "Can't open $input\n";
open(GE,">$input\_genelist");
my $p=0;
foreach my $line (<IN>)
{
  next if (($line !~ m/^GENES/) && (!$p));
  if($line =~ m/^GENES/)
  {
    $p=1;
  }
  if($line =~ m/^\/{3}$/)
  {
    $p=0;
  }
  if($p)
  {
    my @l = split(/\s+/,$line);
    my $org = lc($l[1]);
    my $id = (split(/\(/,$l[2]))[0];
    print GE $org,$id,"\n";
  }
}
close(IN);
