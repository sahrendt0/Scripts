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
my ($infile,$all);
my @files;
my ($help,$verb);
my $hmm_mode = "search";
GetOptions ('i|input=s' => \$infile,
            'a|all'     => \$all,
            'm|mode=s'  => \$hmm_mode,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: summarizePFAM.pl -i input | -a [-m hmm_mode]\nOutput is STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$infile && !$all);

#####-----Main-----#####
if($all)
{
  opendir(DIR,".");
  @files = grep {/\_tbl\.hmm/ } readdir(DIR);
  closedir(DIR);
}
else
{
  push @files,$infile;
}

foreach my $input (@files)
{
  my ($hash_ref,$hits_ref) = hmmParse($input);
  my $in = (split(/[\-|\_]/,$input))[2];
  my %hash = %{$hash_ref};
  my %hits = %{$hits_ref};
  #print Dumper \%hash;
  open(my $oh,">","$in\_pfam.tsv");
  foreach my $key (sort keys %hash)
  {
    print $oh "$key\t";
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
    print $oh join(",",@pfids),"\n";
  }
  my $total = scalar keys %hits;
  warn $total,"\n";
  #warn Dumper \%hits;
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
