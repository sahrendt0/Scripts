#!/usr/bin/perl
# Script: summarizePFAM.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 06.17.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $hmm_mode = "search";
GetOptions ('i|input=s' => \$input,
            'm|mode=s'  => \$hmm_mode,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: summarizePFAM.pl -i input [-m hmm_mode]\nOutput is STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my ($hash_ref,$hits_ref) = hmmParse($input);
my %hash = %{$hash_ref};
my %hits = %{$hits_ref};
#print Dumper \%hash;

foreach my $key (sort keys %hash)
{
  print "$key\t";
  my @pfids;
  if($verb)
  {
    foreach my $id (sort keys %{$hash{$key}})
    {
      push(@pfids, join(";",$id,$hash{$key}{$id}{"Desc"}));
    }
  }
  else
  {
    @pfids = sort keys %{$hash{$key}};
  }
  print join(",",@pfids),"\n";
}
my $total = scalar keys %hits;
print $total,"\n";
print Dumper \%hits;
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
