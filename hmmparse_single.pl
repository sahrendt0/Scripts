#!/usr/bin/perl
# Script: hmmparse_single.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.24.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use Data::Dumper;
#####-----Global Variables-----#####
my $input;
my %hmm_hash;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: hmmparse_single.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
%hmm_hash = hmmParse($input);
foreach my $key (sort {$hmm_hash{$a} <=> $hmm_hash{$b}} keys %hmm_hash)
{
  print $hmm_hash{$key},"\t";
  $key =~ s/-;//;
  print $key,"\n";
}
#print Dumper \%hmm_hash;
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
