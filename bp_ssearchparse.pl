#!/usr/bin/perl
# Script: bp_ssearchparse.pl
# Description: Parses all ssearch files in the given directory; Gathers counts and sequences.
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 3.20.14 
#        Updated for single mode
#####################################
# [x]: Hash of organisms
# [ ]: Array of genes + counts
# [ ]: Hash of genes + counts/names/evals
# [x]: Gather sequences
######################################

use warnings;
use strict;
use lib '/rhome/sahrendt/Scripts';
use Bio::SearchIO;
use Bio::SeqIO;
use Getopt::Long;
use BCModules;
use SeqAnalysis;
use Data::Dumper;

## Structures, variables, etc.
my (%peps, @genes);
my %total_hits; # final data structure for ssearch summary
my $gen_dir = "/rhome/sahrendt/bigdata/Genomes";
my $pep_dir = "$gen_dir/Protein";
my @result_list; # list of ssearch files
my @proteomes;   # list of proteomes
my @genelist;    # list of gene IDs in $genes_file

## Command line options
my $ssearch_dir = ".";   # directory of ssearch results
my $taxonlist_file = "$gen_dir/taxonlist";
my $genes_file; # Fasta file containing gene(s) used in ssearch
my $single_ssearch;
my @total_orgs; # organisms queried
my $verbose;
my $help;
my $abbrev;
my $inprot; # run in single mode, using only one genome and one proteome file

GetOptions ('d|dir=s'      => \$ssearch_dir, 
            'S|single=s'   => \$inprot,
            'ssearch=s'    => \$single_ssearch,
            't|taxon=s'    => \$taxonlist_file,
            'f|fasta=s'    => \$genes_file,
            'v|verbose'    => \$verbose,
            'h|help'       => \$help,
            'a|abbrev=s'   => \$abbrev);

my $usage = "Usage: bp_ssearchparse.pl -f fastafile -t taxon_list -a abbrev\n";
$usage .= "Single usage: bp_ssearchparse.pl -f fastafile -t taxon_list -a abbrev -S proteome [--ssearch ssearchfile]\n";
die $usage if ($help);
die $usage if (!$genes_file);

############
## 0. Check for ssearch files
############
if($single_ssearch)
{
  push @result_list,$single_ssearch;
}
else
{
  opendir(DIR,$ssearch_dir);
  @result_list = grep {/\.SSEARCH$/i} readdir(DIR);
  closedir(DIR);
  if(scalar @result_list == 0)
  {
    warn "Can't find any .ssearch files in directory \"$ssearch_dir\"\n";
    warn "Try a different directory...\n";
    exit;
  }
}

############
## 1. Index proteomes
############
if($inprot)
{
  %peps = indexFasta($inprot);
}
else
{
  %peps = indexProteomes;
}

###########
## 2. Hash of organisms
###########
%total_hits = %{taxonList()};

#open(TX,"<$taxonlist_file") or die "Can't find $taxonlist_file..\n";
#foreach my $line (<TX>)
#{
#  next if $line =~ m/^#/;
#  chomp $line;
#  my ($ID,$cl2,$cl1,$name,$info) = split(/\t/,$line);
#  $total_hits{$ID}{"Class"} = $cl2;
#  $total_hits{$ID}{"Name"} = $name;
#}
#close(TX);

############
## 3. Array of genes + counts
############
my $fasta_in = Bio::SeqIO->new(-format => 'fasta',
                               -file => $genes_file);
while(my $gene = $fasta_in->next_seq())
{
  push (@genelist, $gene->display_id);
}

## Run through ssearch files
foreach my $result_file (@result_list)
{
#  print $result_file,"\t";
  my ($tmp1,$tmp2,$result_id,$ext) = split(/[\-|\.]/,$result_file);
#  print $result_id,"\n";
#  push(@total_orgs, $result_id);
  my $SSEARCH_IO = Bio::SearchIO->new(-format => 'blasttable', # Format = 'blasttable' from -m 8c option of ssearch36
                                      -file => "$ssearch_dir/$result_file");
  my %counts;
  my @hits;
  while( my $result = $SSEARCH_IO->next_result )
  {
    if($verbose){print "Query= ",$result->query_name;}
    my $query= $result->query_name;
    my $num_hits = 0;
    while(my $hit = $result->next_hit)
    {
      push @{$total_hits{$result_id}{"Hits"}{$query}}, $hit->name;
#      $num_hits++;
#      push (@hits, $hit->name);
      if($verbose){print " Hit=",  $hit->name,"\n";}
    }
    #print " ($num_hits)\n";
 #   $counts{$result->query_name} = $num_hits;
  }
  #foreach my $count_key (keys %counts){    print "  $count_key = ",$counts{$count_key},"\n";}
#  push (@{$taxa{$result_id}}, \%counts);
#  push (@{$taxa{$result_id}}, \@hits);   
}
print Dumper \%total_hits;

###############
## 4. Display output in table format
###############
open(OUT,">out_table");
if($verbose){print OUT "Type\t";}
print OUT "Org\t";
foreach my $gene (@genelist)
{
  #my($src,$org,$ID,$code) = split(/\|/,$gene);
  #print OUT "$ID ";
  print OUT "$gene\t";
}
print OUT "\n";
#my $fasta_out = Bio::SeqIO->new(-file => ">>outfile",
#                                -format => "fasta");
foreach my $key (sort keys %total_hits)#keys %taxa)
{
  print OUT "$key\t"; # This prints out Org ID; can also print out full organism name
  foreach my $gene (@genelist)
  {
    #print "$key $taxa{$key}[0] $taxa{$key}[1] ";
    if (exists $total_hits{$key}{"Hits"}{$gene})
    {
      my $count = scalar @{$total_hits{$key}{'Hits'}{$gene}};
      print OUT "$count\t";    # print the count of hits in out_table
      my $fasout = Bio::SeqIO->new(-file => ">$abbrev\_$key\_$gene.faa",
                                   -format => "fasta");
#      my %uq_genes; # unique hits to be printed
      foreach my $item (@{$total_hits{$key}{"Hits"}{$gene}})
      {
        if($verbose){print "\t$item\n";}
        $fasout->write_seq($peps{$item});
      }
    }
    else
    {
      print OUT "0\t";
    }
  }
  print OUT "\n";
}
