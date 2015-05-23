#!/usr/bin/perl
# Script: parseByTax.pl
# Description: Trims an "out_table" file in accordance with a specific set of organisms 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.02.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;
use lib '/rhome/sahrendt/Scripts/';
use SeqAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %out_table;
my $sort;
my @master = rankMaster();  # array of refs: [0] is order (array ref) and [1] is org=>type pair (hash ref)
my @orgs = qw(Amac Bden Cang Clat Gpro Hpol OrpC PirE Rall Spun Ncra Spom Scer Pgra Umay Ccin Rory Crev Pbla Ccor);
my $other_tax; # additional taxa to add to @orgs
my $fullName;  # displays full organism name in output (default is abbreviation)
my $selection; # user-provided subset of gene names (default is all)

GetOptions ('i|input=s' => \$input,
            'other=s' => \$other_tax,
            'select=s' =>\$selection,
            'fullName' => \$fullName,
            'h|help'   => \$help,
            'sort'     => \$sort,
            'v|verbose' => \$verb);
my $usage = "Usage: parseByTax.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh,"<",$input) or die "Can't open $input: $!\n";
my $lc = 0;
my @gene_names;
while (my $line = <$fh>)
{
  chomp $line;
  my @data = split(/\s+/,$line);
  if($lc == 0)
  {
    @gene_names = @data;
  }
  else
  {
    for(my $i=0;$i<scalar(@gene_names); $i++)
    {
      $out_table{$data[0]}{$gene_names[$i]} = $data[$i];
    }
  }
  $lc++;
}
close($fh);

if ($selection)
{
  my @new_gene_names = split(/,/,$selection);
  @gene_names = @new_gene_names;
  unshift (@gene_names,"Org");
}
#print join("-",@gene_names),"\n";
#print Dumper \%out_table;

my $master_rank = $master[1];  # hash ref
my $master_order = $master[0];  # array ref
if($other_tax)
{
  my @tmp = split(/,/,$other_tax);
  foreach my $tax (@tmp)
  {
    push @orgs,$tax;
  }
}
@orgs = keys(%{$master_rank}) if ($sort);

print join("\t",@gene_names),"\n";
shift @gene_names;
#print $master_rank->{"Bden"},"\n";
#print indexOf($master_rank->{"Bden"},$master_order),"\n";

## Sorting/printing function
foreach my $org (sort {indexOf($master_rank->{$a}{"Group"},$master_order) <=> indexOf($master_rank->{$b}{"Group"},$master_order)} keys %{$master_rank})
{
#  print "[$org]\n";
  next if(!(isPresent(\@orgs,$org)));
  #print indexOf($master_rank->{$org},$master_order),"\t";
  #print $master_rank->{$org},"\t";
  if($fullName)
  {
    print $master_rank->{$org}{"FullName"},"\t";
  }
  else
  {
    print $org,"\t";
  }
  foreach my $gene (@gene_names)
  {
    if(exists $out_table{$org})
    {
      print $out_table{$org}{$gene},"\t";
    }
    else
    {
      print "--\t";
    }
  }
  print "\n";
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub isPresent {
  my @ar = @{shift @_};
  my $item = shift @_;
  my $found = 0;
  while(!$found && scalar(@ar))
  {
    my $tmp = shift @ar;
    $found = 1 if ($item eq $tmp);
  }
  return $found;
}

sub indexOf {
  my $search_for = shift @_;
  my @array = @{shift @_};
  my( $index )= grep { $array[$_] eq $search_for } 0..$#array;
  return $index;
}
