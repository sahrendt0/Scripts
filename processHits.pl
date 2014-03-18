#!/usr/bin/perl
# Script: processHits.pl
# Description: Pulls out specific proteins from this Flagellar SSEARCH run 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.18.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use BCModules;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my $geneid;
my %genedesc;
my @hitlist;
my %tax_hash;
my @classArray = qw(CF ZF);
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'g|geneid=s' => \$geneid,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: processHits.pl -g geneid\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);
die "No geneid.\n$usage" if (!$geneid);

#####-----Main-----#####
## Get gene descriptions
open(DESC,"<FMs.txt") or die "Can't open FMs.txt: $!\n";
while (my $line = <DESC>)
{
  chomp $line;
  my ($key,$val) = split(/\t/,$line);
  $genedesc{$key} = $val;
}
close(DESC);

## Get results files
opendir(DIR,".");
@hitlist = grep { /\.ssearch$/i } readdir(DIR);
closedir(DIR);

## Index taxonomy
%tax_hash = indexTaxonomy();

## Process hits
foreach my $file (@hitlist)
{
  my $org = (split(/[-\.]/,$file))[2];
  if(isInArray($tax_hash{$org}{"Class"},\@classArray))
  {
    print "grep $geneid $file | grep \"#\" -v | cut -f 2 | getseqfromfile.pl -f $org\_proteins.aa.fasta -d ~/bigdata/Genomes/Protein/ -a - > $org\_$genedesc{$geneid}\.aa.fasta\n";
    print "cat $org\_$genedesc{$geneid}\.aa.fasta >> $tax_hash{$org}{Class}\_$genedesc{$geneid}\.aa.fasta\n";
    print `grep $geneid $file | grep "#" -v | cut -f 2 | getseqfromfile.pl -f $org\_proteins.aa.fasta -d ~/bigdata/Genomes/Protein/ -a - > $org\_$genedesc{$geneid}\.aa.fasta`;
    print `cat $org\_$genedesc{$geneid}\.aa.fasta >> $tax_hash{$org}{Class}\_$genedesc{$geneid}\.aa.fasta`;
  }
}

#print Dumper \%tax_hash;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub isInArray
{
  my $item = shift @_;
  my $array_ref = shift @_;
  my $isIn = 0;
  foreach my $a (@{$array_ref})
  {
    $isIn = 1 if($item eq $a);
  }
  return $isIn;
}
