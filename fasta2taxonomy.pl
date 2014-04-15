#!/usr/bin/perl
# Script: fasta2taxonomy.pl
# Description: Generates a taxonomy file from species in a Fasta description line 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.13.2014
##################################
# Standard 7:
#   Kingdom, Phylum, Class, Order, Family, Genus, Species
# Extended:
#   Superkingdom, Kingdom, Phylum, Subphylum, Superclass, Class, Superorder, Order, Superfamily, Family, Subfamily, Genus, Species
####
use warnings;
use strict;
use lib '/rhome/sahrendt/Scripts';
use Bio::Seq;
use Bio::SeqIO;
use SeqAnalysis;
use Getopt::Long;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $hash_ref;
my $db_form = "flatfile";
my @ranks = qw(Kingdom Phylum Class Order Family Genus Species); # Standard 7 taxonomic rankings

GetOptions ('i|input=s' => \$input,
            'd|db=s' => \$db_form,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: fasta2taxonomy.pl -i input [-d database_format]\nDB format default is \"flatfile\"\nOutput to STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(IN,"<$input") or die "Can't open $input: $!\n";
while(my $accno = <IN>)
{
  chomp $accno;
  print "<$accno>" if $verb;
  my @tmp = split(/\_/,$accno);
  my $genus = $tmp[0];
  my $species = $tmp[1];
  #shift @tmp;
  my $name = join(" ",$genus,$species);
  print "<$name>" if $verb;
  $hash_ref->{$name} = getTaxonomy($name,$db_form,$verb);
  if($hash_ref->{$name}{"kingdom"} ne "NULL")
  {
    #print "$accno\t";
    printTaxonomy($hash_ref,\@ranks,$name,$accno);
  }
  else
  {
    open(my $fh,">>","Failed");
    print $fh "$accno\n";
    close($fh);
  }
  #print "<<$accno>>" if $verb;
}
#printTaxonomy($hash_ref,\@ranks);

#print Dumper $hash_ref;
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
