#!/usr/bin/perl
# Script: parseOrthoMCL.pl
# Description: Summarizes OrthoMCL output 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.13.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %groups;
my $taxHash = taxonList();
my $Joneson; # table from Joneson paper

GetOptions ('i|input=s' => \$input,
            'j|joneson=s' => \$Joneson,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: parseOrthoMCL.pl -i input\nSummarizes OrthoMCL output\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
## Step 0: get orgs list
opendir(DIR,"compliantFasta");
my @orgList = grep { /\.fasta$/ } readdir(DIR);
closedir(DIR);
for(my $i=0;$i<scalar(@orgList);$i++)
{
  $orgList[$i] = (split(/\./,$orgList[$i]))[0];
}

## Step 1: read mclOutput and store in hash
open(my $fh,"<",$input) or die "Can't open $input: $!\n";
my $grp = 0;
while(my $line = <$fh>)
{
  chomp $line;
  my @cluster = split(/\t/,$line);
  $groups{$grp}{"Data"} = $line;
  foreach my $prot (@cluster)
  {
    my $org = (split(/\|/,$prot))[0];
    $groups{$grp}{$org}{"Counts"}++;
    push (@{$groups{$grp}{$org}{"Data"}},$prot);
  }
  $grp++;
}
close($fh);

## Step 2: Print whole table
printTable(\@orgList,\%groups);

## Step 3: get uniq groups
#showUniqGroups(\%groups);

## Step 4: read in a new table
#my %new_groups = readNewTable($Joneson);
#showUniqGroups(\%new_groups);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub readNewTable {
  my $in = shift @_;
  my %new_table;
  open(my $fh, "<",$in);
  my @orgs;
  while(my $line = <$fh>)
  {
    chomp $line;
    my ($group,@data) = split(/\t/,$line);
    if($group eq "FAMILY")
    {
      @orgs = @data;
    }
    else
    {
      $group = (split(/\_/,$group))[1];
      for(my $i=0;$i<scalar(@data);$i++)
      {
        next if($data[$i] == 0);
        $new_table{$group}{$orgs[$i]}{"Counts"} = $data[$i];
      }
    }
  }
  close($fh);
  
  return %new_table;
}
sub printTable {
  my @orgList = @{shift @_};
  my %data = %{shift @_};
  my @sorted_orgList = @{sortByTax(\@orgList)};

  print "group\t",join("\t",@sorted_orgList),"\tmembers\n";
  foreach my $key (sort {$a <=> $b} keys %data)
  {
    print $key,"\t";
    for(my $i=0;$i<scalar(@sorted_orgList);$i++)
    {
      if(exists($data{$key}{$sorted_orgList[$i]}{"Counts"}))
      {
        print $data{$key}{$sorted_orgList[$i]}{"Counts"};
      }
      else
      {
        print "0";
      }
      print "\t";
    }
    print $data{$key}{"Data"},"\n";
  }
}

sub indexOf {
  my $search_for = shift @_;
  my @ar = @{shift @_};
  my( $index ) = grep { $ar[$_] eq $search_for } 0..$#ar;
  return $index;
}

sub sortByTax {
  my @list = @{shift @_};  #unsorted list of orgs used in this analysis
  my @master_ar = rankMaster();
  my $master_rank = $master_ar[1];
  my $master_order = $master_ar[0]; # ref of sorted array (taken from master taxonlistID
  #my @tmp = @{$master_order};
 # print $tmp[0];
#  my @sorted_list = @list;
  my @sorted_list = sort {indexOf($master_rank->{$a}{"Group"},$master_order) <=> indexOf($master_rank->{$b}{"Group"},$master_order)} @list;
  return \@sorted_list;
}

sub showUniqGroups {
  my %data = %{shift @_};
  foreach my $group (sort {$a <=> $b} keys %data)
  {
    my @orgs = keys %{$data{$group}};
    next if (scalar(@orgs) > 1);
    print "$group: $orgs[0] => ",$data{$group}{$orgs[0]}{"Counts"},"\n";
  }
}
