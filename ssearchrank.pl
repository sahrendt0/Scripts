#!/usr/bin/perl
# Script ssearchrank.pl
# Description: Takes accession numbers and searches many .ssearch files to get the highest scoring match
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.18.2013
##################################
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

## Hash other score files
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
          $ssearch{$result->query_name}{$hit_org}{$hit->name}{"eval"} = $hsp->evalue;
        }
      }
    }
  }
}

#print join("\n",@ssearch_files);

print Dumper \%ssearch;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
