#!/usr/bin/perl
# Script: test_tax.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.12.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
#my @ranks = qw(kingdom phylum class order family genus species);
my @ranks = qw(phylum);		# user input for ranks to use

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: test_tax.pl -i input [--ranks]\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
#@ranks = split(/,/,$user_ranks) if $user_ranks;
my $tax_db = initNCBI("flatfile");
open(IN,"<",$input) or die "Can't open $input: $!\n";
while(my $line = <IN>)
{
  chomp $line;
  my @tmp = split(/ /,$line);
  $line = join("\t",@tmp);
  my $id = (split(/\t/,$line))[1];
  my $hash = getTaxonomybyID($tax_db,$id);
  print $line,"\t";
  printTaxonomy($hash,\@ranks,"",$id);
}

close(IN);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
