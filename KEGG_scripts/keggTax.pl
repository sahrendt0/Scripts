#!/usr/bin/perl
# Script: kegg.pl
# Description: Queries the KEGG db to collect taxonomic info
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.10.14
################################
# Usage: kegg.pl -o operation -a argument -w output
#    where operation:   info
#			list
#			find
#			get
#			conv
#			link
#################################
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
#print Dumper $LOCAL_TAX;
my $BCMO1_accnos = "BCMO1.accnos";
my $BCDO2_accnos = "BCDO2.accnos";
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

## hash up genelist
open(my $BC1, "<",$BCMO1_accnos) or die "Can't open $BCMO1_accnos: $!\n";
while(my $line = <$BC1>)
{
  chomp $line;
  $genelist{$line} = "BCMO1";
}
close($BC1);
open(my $BC2, "<",$BCDO2_accnos) or die "Can't open $BCDO2_accnos: $!\n";
while(my $line = <$BC2>)
{
  chomp $line;
  $genelist{$line} = "BCDO2";
}
close($BC2);
$genelist{"unk"} = "unk";
## Open codefile
open(my $code_h,"<",$input) or die "Can't open $input: $!\n";
while (my $line = <$code_h>)
{
  chomp $line; 
  my $taxid;
  if($line =~ /\w{4}\|/)
  {
    my $localID = (split(/\|/,$line))[0];
    $taxid = $LOCAL_TAX->{lc($localID)}{"TaxID"};
  }
  my $gene_name = "unk";
  if(!$taxid)
  {
    $gene_name = (split(/\t/,$line))[0];
    $gene_name =~ s/_/:/;
    my $keggGN = (split(/:/,$gene_name))[0];
    $taxid = kegg2tax($keggGN);
  }
  my $taxHash = getTaxonomybyID($NCBI_TAX,$taxid);
  print "$line\t$genelist{$gene_name}\t";
  printTaxonomy($taxHash,\@ranks,"",$taxid);
}
close($code_h);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub isChytrid {
  my $id = shift @_;
  my $taxid = 0;
  if($id =~ /SPPG/i)
  {
    $taxid = 645134; # Spun
  }
  elsif($id =~ /CANG/i) 
  {
    $taxid = 765915; # Cang
  }
  elsif($id =~ /AMAG/i)
  {
    $taxid = 578462; # Amac
  }
  elsif($id =~ /Clat/i)
  {
    $taxid = 945690;  # Clat
  }
  elsif($id =~ /Bden/i)
  {
    $taxid = 403673; # Bden 423
  }
  return $taxid;
}

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

