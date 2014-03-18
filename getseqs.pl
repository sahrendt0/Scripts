#!/usr/bin/perl -w
# Script: getseqs.pl
# Description: Retrieve sequences from GenBank based accession numbers found in the input file
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 4.29.13
#         v1.0  : Initial
#         v1.1  : genbank/fasta output
#         v1.2  : updated for different inputfile
#         v1.3  : added extra parameters
#####################################
# Usage: getseqs.pl [-g] -i accnos_file [-s startpos] [-e endpos] [-b blocksize]
#####################################

use strict;
use Bio::Seq;
use Bio::SeqIO;
use Bio::DB::EUtilities;
use Getopt::Long;

## Vars
my $genbank = 0;      # get genbank format
my $format = "fasta"; # default file format
my $ext = "fasta";    # default file extension
my $accnosfile = "";  # input accnos file
my $end_pos = -1;     # position in the list to end
my $start_pos = 0;    # position in the list to start
my $block_size = 100; # number of sequences to fetch at once
my $help=0;
GetOptions('g'             => \$genbank,
           'i|input=s'     => \$accnosfile,
           'b|blocksize=i' => \$block_size,
           's|startpos=i'  => \$start_pos,
           'e|endpos=i'    => \$end_pos,
           'h'             => \$help
           );
 
if($help)
{
  print "Usage: getseqs.pl [-g] -i accnos_file [-s startpos] [-e endpos] [-b blocksize]\n";
  exit;
}
#my $accnosfile = $ARGV[0];
die "No input file!\n" if ($accnosfile eq "");
if($genbank)
{
  $format = "genbank";
  $ext = "gb";
}
my @accnosname = split(/\./,$accnosfile);
my $outputfile = join("\.",$accnosname[0],$ext);

## Get the accessions
open(ACCNOS,"<$accnosfile") or die "Cannot open $accnosfile\n";
my @accnos = <ACCNOS>;
close(ACCNOS);
chomp @accnos;

## Remove header line
if($accnos[0] =~ m/^#/){shift @accnos;}

## Can only download so many at a time, so set up 'blocks' of sequences to fetch
my $c = $start_pos;  # initial counter
my $num_items = @accnos;
if($end_pos >= 0)
{
  $num_items = $end_pos;
}
while($c < $num_items)
{
  my $end = ($c+($block_size-1));
  if($end >= $num_items)
  {
    $end = ($num_items-1);
  }
  print "[$c..$end]\t$num_items\n"; #scalar @accnos[$c,($c + ($block_size-1))];
  #print join(" ",@accnos[$c..$end]),"\n";

  my @subset = @accnos[$c..$end];
  my $efetch_factory = Bio::DB::EUtilities->new(-eutil   => 'efetch',
                                                -db      => 'protein',
                                                -rettype => $format,
                                                -email   => 'sahrendt0@gmail.com',
                                                -id      => \@subset);

  my $out = "$outputfile\.$c";
  $efetch_factory->get_Response(-file   => $out,
                                -format => $format);

  $c += $block_size;
#  $fc += 100;
  sleep(5);
}
