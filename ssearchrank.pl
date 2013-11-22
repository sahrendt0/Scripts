#!/usr/bin/perl
# Script ssearchrank.pl
# Description: Searches many FASTA search result files to get a better scoring match for a particular transcript
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.18.2013
##################################
# Usage: ssearchrank.pl -i score_file
#################################
# Read through the scores file, which contains (tab-delimited) accession number and e-val score
#   - scores file was made Using unix "cut" on the report file
#   - ssearchrank.pl *could* be made to take the report file directly
# Next, read through each of the ssearch results files
# If the score for a particular transcript is better in the ssearch result file compared to the initial query
#   - store it in the hash
# Then for each transcript
#   - sort all hits across all different species
#   - only report the top hit IF it didn't come from Piromyces
###################################

use warnings;
use strict;
use Getopt::Long;
use Bio::SearchIO;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $dir = ".";
my $score_file;
my @ssearch_files;

my %score;
my %ssearch;
my %best = ("prev" => 0,
            "best" => 0,
            "file" => "");
GetOptions ('i|input=s'  => \$score_file,
            'h|help'     => \$help,
            'v|verbose'  => \$verb,
            'd|dir=s'    => \$dir);

my $usage = "Usage: ssearchrank.pl -i score_file\n";
die $usage if $help;
die "No score file: $!\n$usage" if (!$score_file); 

#####-----Main-----#####
## Open score file
open(ACC,"<$score_file") or die "Can't open $score_file: $!\n";
while(my $line = <ACC>)
{
  chomp $line;
  my @data = split(/\t/,$line);
  if(scalar @data == 2)
  {
    $score{$data[0]} = $data[1]; # store data as key, score as value
  }
}
close(ACC);

## Hash result files
opendir(DIR,$dir);
@ssearch_files = grep {/\.ssearch$/} readdir(DIR);
closedir(DIR);
foreach my $file (@ssearch_files)
{
  my $hit_org = (split(/[-\.]/,$file))[2];
  #print $hit_org,"\n";
  my $ssearch_io = Bio::SearchIO->new(-file => "<$file",
                                      -format => "blasttable");
  while(my $result = $ssearch_io->next_result)
  {
    while(my $hit = $result->next_hit)
    {
      while (my $hsp = $hit->next_hsp)
      {
        if($hsp->evalue < $score{$result->query_name})
        {
          #print $score{$result->query_name}, " : ", $hsp->evalue,"\n";
          $ssearch{$result->query_name}{$hit_org}{$hit->name} = $hsp->evalue;
        }
      } # while hsp
    } # while hit
  } # while result
} # foreach

## 
# Flatten the hash a little so that we can sort only on the scores
my %flat_hash;
#print "Gene\tHit Org\tcount\tTop scoring\n";
foreach my $gene (keys %ssearch)
{
  foreach my $org (keys %{$ssearch{$gene}})
  {
    foreach my $hit (keys %{$ssearch{$gene}{$org}})
    {
      my $flat_key = join("\t",$org,$hit);
      $flat_hash{$gene}{$flat_key} = $ssearch{$gene}{$org}{$hit};
    }
#    my @scores = sort { $ssearch{$gene}{$org}{$a} <=> $ssearch{$gene}{$org}{$b} } keys %{$ssearch{$gene}{$org}};
#    print "$gene\t";
#    print "$org\t";
#    print scalar(@scores),"\t";
#    print $ssearch{$gene}{$org}{$scores[0]},"\n";
  }
}

##
# Print out the flattened hash, sorted by the scores
# Basically, for each transcript, want to see what the best hit is across all ssearch results files
##
# Filter out things that hit Piromyces
# This way, we can see if poorly scoring Neocallo hits were just called incorrectly
open(RE,">rescored");
print RE "Gene\tHit Org\tTop hit\tScore\tOld Score\n";
foreach my $gene (sort keys %flat_hash)
{
  my @keys = sort { $flat_hash{$gene}{$a} <=> $flat_hash{$gene}{$b} } keys %{$flat_hash{$gene}};
  next if ($keys[0] =~ /PirE/i);
  print RE "$gene\t";
  print RE "$keys[0]\t";
  print RE $flat_hash{$gene}{$keys[0]},"\t";
  print RE $score{$gene},"\n";
}
close(RE);

#print Dumper \%flat_hash;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
