#!/usr/bin/perl
# Script: parseKEGGgenes.pl
# Description: Groups downloaded entries into phylogenetic groups
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.13.15
################################
# KEGG API: http://www.kegg.jp/kegg/rest/keggapi.html
#################################

use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts/';
use SeqAnalysis;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my @ranks = @STD_TAX;
my $user_ranks;
my $NCBI_TAX = initNCBI("flatfile");
my $LOCAL_TAX = taxonList(); # local hash reference for genomes on biocluster
my %genelist;
my $kegg_local = "/rhome/sahrendt/bigdata/Data/KEGG";

GetOptions ("i|input=s"     => \$input,
            "ranks=s"       => \$user_ranks,
            "v|verbose"     => \$verb,
            "h|help"        => \$help);
my $usage = "Usage: kegg.pl -i input\n";
die $usage if($help);
#$output = $arg;

#####-----Main-----#####
## Get user ranks
@ranks = split(/,/,$user_ranks) if ($user_ranks);

## get all fasta files
opendir(DIR,".");
my @files = grep { /\.faa$/ } readdir(DIR);
closedir(DIR);

@ranks = qw(Kingdom);

foreach my $file (@files)
{
  my $keggGN = (split(/:/,$file))[0];
  my $taxid = kegg2tax($keggGN);
  my $taxHash = getTaxonomybyID($NCBI_TAX,$taxid);
  my $str = printTaxonomy($taxHash,\@ranks,"",$taxid);
  my $dir = (split(/__/,$str))[1];
  system("mkdir $dir") unless (-d $dir);
  system("mv $file $dir");
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub kegg2tax {
  my $orgID = shift @_;
  my $taxID;
  opendir(DIR,$kegg_local);
  my %local_db = map {$_ => 1} grep {/\w{3}/} readdir(DIR);
  closedir(DIR);
  if(!exists $local_db{$orgID})
  {
    warn "$orgID not found locally" if ($verb);
    `wget -q -O $kegg_local/$orgID http://rest.kegg.jp/get/gn:$orgID` if (!(-e $orgID));
  }
  open(my $fh, "<", "$kegg_local/$orgID") or die "Can't open $orgID: $!\n";
  while(my $line = <$fh>)
  {
    chomp $line;
    next if ($line !~ /^TAX/);
    $taxID = (split(/:/,$line))[1];
  }
  close($fh);
  #`rm $orgID`;
  return $taxID;
}

