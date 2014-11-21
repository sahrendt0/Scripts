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

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %out_table;
my $sort;
my @master = rankMaster();
my @orgs = qw(Amac Bden Cang Clat Gpro Hpol OrpC PirE Rall Spun Ncra);
my $other_tax; # additional taxa to add to @orgs
my $fullName;

GetOptions ('i|input=s' => \$input,
            'other=s' => \$other_tax,
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
foreach my $org (sort {indexOf($master_rank->{$a}{"Group"},$master_order) <=> indexOf($master_rank->{$b}{"Group"},$master_order)} keys %{$master_rank})
{
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
    print $out_table{$org}{$gene},"\t";
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


########
### Subroutine: rankMaster
##
##############
sub rankMaster {
  my @results; # will store two refs: array ref for rank order, and hash ref for org => type pair
  my @ordered_ranks;
  my $rank_level = 2;
  my %hash;
  my $file = "/rhome/sahrendt/bigdata/Genomes/taxonlist";
  open(IN,"<",$file) or die "Can't open $file: $!\n";
  while (my $line = <IN>)
  {
    chomp $line;
    if($line =~ /^\#\@$rank_level/)
    {
      $line =~ s/^\#\@$rank_level//;
      @ordered_ranks = split(/,/,$line);
      push @results, \@ordered_ranks;
    }
    elsif($line !~ /^#/)
    {
      my @data = split(/\t/,$line);
      
      $hash{$data[0]}{"Group"} = $data[1];
      $hash{$data[0]}{"FullName"} = $data[3];
    }
  }
  close(IN);
  push @results, \%hash;
  return @results;
}
