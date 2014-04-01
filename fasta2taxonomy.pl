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
my $db_form = "entrez";
my @ranks = qw(Kingdom Phylum Class Order Family Genus Species); # Standard 7 taxonomic rankings

GetOptions ('i|input=s' => \$input,
            'd|db=s' => \$db_form,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: fasta2taxonomy.pk -i input [-d 'flatfile']\nOutput to STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(IN,"<$input") or die "Can't open $input: $!\n";
while(my $name = <IN>)
{
  chomp $name;
  $hash_ref->{$name} = getTaxonomy($name,$db_form);
  #print $name,"\t";
}
printTaxonomy($hash_ref);

#print Dumper $hash_ref;
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub printTaxonomy
{
  my $tax = shift @_;
  my %tax_hash = %{$hash_ref};
  foreach my $name (sort keys %tax_hash)
  {
    print $name,"\t";
    for(my $rc = 0; $rc < scalar(@ranks);$rc++)
    {
      my $rank = lc($ranks[$rc]);
      my $fl = (split(//,$rank))[0];
      print "$fl\__";
      if (exists $tax_hash{$name}{$rank})
      {
        print $tax_hash{$name}{$rank};
      }
      else
      {
        print "no_rank";
        ## todo: fuzzy match to existing ranks
        #  eg. if no_rank is "class", grab "subclass" instead
      }
      print ";" if($rc != (scalar(@ranks)-1));
    }
    print "\n";
  }
}
