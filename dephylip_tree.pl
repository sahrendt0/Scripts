#!/usr/bin/perl 
# Script: dephylip_tree.pl
# Description: Dephylips Newick tree files
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.15.13
######################################
# Usage: dephylip_tree.pl -i treefile -c codefile
######################################
use warnings;
use strict; 
use Bio::TreeIO;
use Getopt::Long;

#####-----Global variables-----#####
my $treefile;
my $code_filename;
my %hash;
my ($help,$verb);
my $encode;
GetOptions ("i|input=s" => \$treefile,
            "c|code=s"  => \$code_filename,
            "h|help"    => \$help,
            "v|verbose" => \$verb,
            "e|encode"  => \$encode);

my $usage = "Usage: dephylip_tree.pl -i treefile -c codefile [-e]\n Use -e to encode\n Output to files\n";

die $usage if ($help);
die $usage if (!$treefile or !$code_filename);

my $treeIn = Bio::TreeIO->new(-file => $treefile,
                              -format => 'newick');

my $treeOutNwk = Bio::TreeIO->new(-file => ">$treefile\.newick",
                                  -format => 'newick');

my $treeOutNex = Bio::TreeIO->new(-file => ">$treefile\.nex",
                                  -format => 'nexus');

## Code files is in format: Name\s+Code
open(IN,"<$code_filename") || die "Can't open \"$code_filename\".\n";
foreach my $line (<IN>)
{
  chomp $line;
  my ($val,$key) = split(/\t/,$line);
  if($encode)
  {
    my $tmp = $key;
    $key = $val;
    $val = $tmp;
  }
  $hash{$key} = $val;
}
close(IN);

my $tree_obj = $treeIn->next_tree;
my $n = 0;
for my $node ($tree_obj->get_leaf_nodes)
{
  my $ID = $node->id;
  my $newID = $hash{$ID};
  print $node->id;
  print " => ";
  $node->id($newID);
  print $node->id;
  print "\n";
  $n++;
}
$treeOutNwk->write_tree($tree_obj);
$treeOutNex->write_tree($tree_obj);
