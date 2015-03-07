#!/usr/bin/perl
# Script: kegg2tax.pl
# Description: Print tax hierarchy for kegg ID 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.26.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $NCBI_TAX = initNCBI("flatfile");
my @ranks = @STD_TAX;
my $LOCAL_TAX = taxonList();

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: kegg2tax.pl -i input\nPrint tax hierarchy for kegg ID\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $taxid = kegg2tax($input);
my $taxHash = getTaxonomybyID($NCBI_TAX,$taxid);
printTaxonomy($taxHash,\@ranks,"",$taxid);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
