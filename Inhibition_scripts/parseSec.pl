#!/usr/bin/perl
# Script: parseSec.pl
# Description: Collects and collapses all secretome PFAM prediction data 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.14.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my $curr_dir = "/rhome/sahrendt/bigdata/Inhibition/secretome/workflow/";
my %master;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: parseSec.pl -i input\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
opendir(DIR,$curr_dir);
my @dirs = sort grep { -d && /\w+/ && $_} readdir(DIR);
closedir(DIR);
warn "@dirs\n" if $verb;

foreach my $dir (@dirs)
{
  my $hmm_result = "$curr_dir/$dir/hmmsearch/PFAM10-vs-$dir\_tbl.hmmsearch";
  if(-e $hmm_result)
  {
    $master{$dir} = hmmParse($hmm_result,"ref");
  }
}
my @total_ids = getPFAMIDs(\%master);
warn Dumper \%master if $verb;

print join("\t","ID",sort keys %master),"\n";
foreach my $id (@total_ids)
{
  print $id,"\t";
  foreach my $org (sort keys %master)
  {
    if(exists $master{$org}{$id})
    {
      print $master{$org}{$id};
    }
    else
    {
      print "0";
    }
    print "\t";
  }
  print "\n";
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getPFAMIDs {
  my %hash = %{shift @_};
  my %ids;
  foreach my $key (sort keys %hash)
  {
    foreach my $id (sort keys %{$hash{$key}})
    {
      $ids{$id}++;
    }
  }
  warn Dumper \%ids if $verb;
  return sort keys %ids;
}
