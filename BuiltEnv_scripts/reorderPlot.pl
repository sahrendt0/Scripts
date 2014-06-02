#!/usr/bin/perl
# Script: /rhome/sahrendt/Scripts/BuiltEnv_scripts/reorderPlot.pl
# Description: Reorders columns to represent lat/country (Amend dataset)
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.31.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Data::Dumper;

#####-----Global Variables-----#####
my ($input,$map);
my @levels;
my %data_hash;  # holds taxonomy data
my %country_hash; # holds SampleID to country map data
my %sort_hash = ( 'Australia'      => 10,
                  'Canada'         => 1,
                  'Indonesia'      => 7,
                  'Mexico'         => 5,
                  'Micronesia'     => 6,
                  'Netherlands'    => 2,
                  'South Africa'   => 8,
                  'United Kingdom' => 3,
                  'United States of America' => 4,
                  'Uruguay'        => 9); # holds country order data (By latitude)
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'm|map=s'   => \$map,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: /rhome/sahrendt/Scripts/BuiltEnv_scripts/reorderPlot.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);
die "No map.\n$usage" if (!$map);

#####-----Main-----#####

%country_hash = getMapHash($map);

open(my $inH, "<", $input) or die "Can't open $input: $!\n";
my @keys; # sampling location keys
my $lc = 0; # line counter
while (my $line = <$inH>)
{
  chomp $line;
  if($line =~ /^Taxon/)
  {
    @keys = split(/\t/,$line);
    shift @keys;
    foreach my $key (@keys)
    {
      $data_hash{$key}{'Country'}{'Name'} = $country_hash{$key};
      $data_hash{$key}{'Country'}{'Order'} = $sort_hash{$country_hash{$key}};
    }
  }
  else
  {
    my ($tax_level,@data) = split(/\t/,$line);
    push @levels,$tax_level;
    for (my $i=0; $i<scalar(@keys); $i++)
    {
      $data_hash{$keys[$i]}{$tax_level}{'Data'} = $data[$i];
      $data_hash{$keys[$i]}{$tax_level}{'Order'} = $lc;
    }
  }
  $lc++;
}
close($inH);

#print Dumper \%data_hash;


## Output: sort by geographic order, then sort by taxon class order (if possible)
print "Taxon\t";
print join("\t",@levels),"\n";
my @countries = sort {$data_hash{$a}{'Country'}{'Order'} <=> $data_hash{$b}{'Country'}{'Order'}} keys %data_hash;
foreach my $key (@countries)
{
  print "$data_hash{$key}{'Country'}{'Name'}\_$key\t";
  foreach my $tax_level (@levels)
  {
    next if ($tax_level eq "Country");
    print $data_hash{$key}{$tax_level}{'Data'},"\t";
  }
  print "\n";
}

#print Dumper \%sort_hash;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getMapHash {
  my %map_hash;
  my $map = shift @_;
  open(my $mapH, "<", $map) or die "Can't open $map: $!\n";
  while (my $line = <$mapH>)
  {
    chomp $line;
    next if($line =~ /^#/);
    my ($key,$val) = split(/\t/,$line);
    my @tmp = split(/\:/,$val);
    $val = $tmp[1];
    $map_hash{$key} = $val;
  }
  close($mapH);
  return %map_hash;
}
