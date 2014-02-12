#!/usr/bin/perl
# Script: bp_ssearchparse.pl
# Description: Parses all ssearch files in the given directory; Gathers counts and sequences.
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.18.13
#####################################
# [x]: Hash of organisms
# [ ]: Array of genes + counts
# [ ]: Hash of genes + counts/names/evals
# [x]: Gather sequences
######################################

use warnings;
use strict;
use Bio::SearchIO;
use Bio::SeqIO;
use Getopt::Long;

## Structures, variables, etc.
my (%peps, %taxa, @genes);
my $gen_dir = "/rhome/sahrendt/bigdata/Genomes";
my $pep_dir = "$gen_dir/Protein";
my @result_list; # list of ssearch files
my @proteomes;   # list of proteomes
my @genelist;    # list of gene IDs in $genes_file

## Command line options
my $ssearch_dir = ".";   # directory of ssearch results
my $taxonlist_file = "$gen_dir/taxonlist";
my $genes_file; # Fasta file containing gene(s) used in ssearch
my @total_orgs; # organisms queried
my $verbose;
my $help;
my $abbrev;
GetOptions ('d|dir=s'    => \$ssearch_dir, 
            't|taxon=s'  => \$taxonlist_file,
            'f|fasta=s'  => \$genes_file,
            'v|verbose'  => \$verbose,
            'h|help'     => \$help,
            'a|abbrev=s' => \$abbrev);

my $usage = "Usage: bp_ssearchparse.pl -f fastafile -t taxon_list -a abbrev\n";
die $usage if ($help);
die $usage if (!$genes_file);

############
## 0. Check for ssearch files
############
opendir(DIR,$ssearch_dir);
@result_list = grep {/\.SSEARCH/i} readdir(DIR);
closedir(DIR);
if(scalar @result_list == 0)
{
  warn "Can't find any .ssearch files in directory \"$ssearch_dir\"\n";
  warn "Try a different directory...\n";
  exit;
}

############
## 1. Index proteomes
############
opendir(PEP,"$pep_dir");
@proteomes = grep{ /\.fasta$/ } readdir(PEP);
closedir(PEP);

foreach my $prot (@proteomes)
{
  if($verbose){print $prot,"\n";}
  my $spec = (split(/\_/,$prot))[0];
  $spec = substr($spec,0,4);
  print $spec,"\n";
  my $seqio_obj = Bio::SeqIO->new(-file => "$pep_dir/$prot",
                                  -format => 'fasta');
  while(my $seq = $seqio_obj->next_seq)
  {
    my $trunc_id = $seq->display_id;
    if(length($trunc_id) > 50)
    {
      $trunc_id = substr($trunc_id,0,50);
    }
    $peps{$spec}{$trunc_id} = $seq;
  }
}

###########
## 2. Hash of organisms
###########
open(TX,"<$taxonlist_file") or die "Can't find $taxonlist_file..\n";
foreach my $line (<TX>)
{
  next if $line =~ m/^#/;
  chomp $line;
  my ($ID,$type,$name) = split(/\t/,$line);
  #$ID = substr($ID,0,4);
  my @info = ($type,$name);
  $taxa{$ID} = \@info;
#  print "<$ID><$type><$name>\n";
}
#foreach my $key (keys %taxa){  print "$key = ",$taxa{$key}[0],"\n"}
close(TX);

############
## 3. Array of genes + counts
############
my $fasta_in = Bio::SeqIO->new(-format => 'fasta',
                               -file => $genes_file);
while(my $gene = $fasta_in->next_seq())
{
  #print $gene->display_id,"\n";
  push (@genelist, $gene->display_id);
}

## Run through ssearch files
foreach my $result_file (@result_list)
{
#  print $result_file,"\t";
  my ($tmp1,$tmp2,$result_id,$ext) = split(/[\-|\.]/,$result_file);
#  print $result_id,"\n";
  push(@total_orgs, $result_id);
  my $SSEARCH_IO = Bio::SearchIO->new(-format => 'blasttable', # Format = 'blasttable' from -m 8c option of ssearch36
                                      -file => "$ssearch_dir/$result_file");
  my %counts;
  my @hits;
  while( my $result = $SSEARCH_IO->next_result )
  {
    if($verbose){print "Query= ",$result->query_name;}#,"\n";}
    my $num_hits = 0;
    while(my $hit = $result->next_hit)
    {
      $num_hits++;
      push (@hits, $hit->name);
      if($verbose){print " Hit=",  $hit->name,"\n";}
    }
    #print " ($num_hits)\n";
    $counts{$result->query_name} = $num_hits;
  }
  #foreach my $count_key (keys %counts){    print "  $count_key = ",$counts{$count_key},"\n";}
  push (@{$taxa{$result_id}}, \%counts);
  push (@{$taxa{$result_id}}, \@hits);   
}

###############
## 4. Display output in table format
###############
open(OUT,">out_table");
if($verbose){print OUT "Type ";}
print OUT "Org ";
foreach my $gene (@genelist)
{
  #my($src,$org,$ID,$code) = split(/\|/,$gene);
  #print OUT "$ID ";
  print OUT "$gene ";
}
print OUT "\n";
#my $fasta_out = Bio::SeqIO->new(-file => ">>outfile",
#                                -format => "fasta");
foreach my $key (sort @total_orgs)#keys %taxa)
{
  if($verbose){print "$taxa{$key}[0] ";}
  print OUT "$key "; # This prints out Org ID; can also print out full organism name
  foreach my $gene (@genelist)
  {
    #print "$key $taxa{$key}[0] $taxa{$key}[1] ";
    if (exists $taxa{$key}[2]{$gene})
    {
      print OUT "$taxa{$key}[2]{$gene} ";
      my $fasout = Bio::SeqIO->new(-file => ">$abbrev\_$key.faa",
                                   -format => "fasta");
      my %uq_genes; # unique hits to be printed
      foreach my $item (@{$taxa{$key}[3]})
      {
        if(!exists $uq_genes{$item})
        {
          if($verbose){print "\t$item\n";}
          $fasout->write_seq($peps{$key}{$item});
          $uq_genes{$item} = 1;
        }
      }
    }
    else
    {
      print OUT "0 ";
    }
  }
  print OUT "\n";
}

## Gather sequences (fix this part to make individual files)
#my $fasta_out = Bio::SeqIO->new(-file => ">outfile",
 #                               -format => "fasta");
#foreach my $ID (@genes){  if($verbose){print "$ID\n";}  $fasta_out->write_seq($peps{$ID});}
