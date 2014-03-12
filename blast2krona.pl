#!/usr/bin/perl
# Script: blast2krona.pl
# Description: Takes BLAST results and creates a Krona data file 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 02.19.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::SearchIO;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %results;
my %tax_hierarchy;
my $taxfile = "/rhome/sahrendt/bigdata/Genomes/tax_hierarchy";

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: blast2krona.pl -i input\nOutput to STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(TAX,"<$taxfile");
while(my $line = <TAX>)
{
  next if ($line =~ /^#/);
  chomp $line;
  my @data = split(/\t/,$line);
  $tax_hierarchy{$data[0]} = $data[1];
}
#print Dumper \%tax_hierarchy;

my $blast_io = Bio::SearchIO->new(-file => $input,
                                  -format => "blasttable");

while(my $result = $blast_io->next_result)
{
  while( my $hit = $result->next_hit )
  {
#    print $hit->name,"\n";
    my $species = (split(/\|/,$hit->name))[0];
    $results{$species}++;
  }
}

foreach my $key (sort keys %results)
{  
  print $results{$key},"\t";
  if($key =~ /Npar/)
  {
    $key = "Npar";
  }
  my $tmp = $tax_hierarchy{$key};
#  print $tmp,"\n";
  $tmp =~ s/;/\t/g;
  print $tmp,"\n";
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
