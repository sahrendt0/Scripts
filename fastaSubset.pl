#!/usr/bin/perl
# Script: fastaSubset.pl
# Description: Takes a large fasta file and parses it into several smaller fasta files containing the desired number of sequences 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 09.17.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my $size = 1000;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            's|size=s' => \$size,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: fastaSubset.pl -i input\nTakes a large fasta file and parses it into several smaller fasta files containing the desired number of sequences\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

my $seqin_obj = Bio::SeqIO->new(-file => $input,
                                -format => "fasta");

my $seq_c = 0; # seq counter
my $file_c = 0; # file counter

while(my $seq_obj = $seqin_obj->next_seq)
{
  if($seq_c == $size)
  {
    $seq_c = 0;
    $file_c++;
  }
  my $seqout_obj = Bio::SeqIO->new(-file => ">>$input\.$file_c",
                                   -format => "fasta");
  $seqout_obj->write_seq($seq_obj);
 # print "$seq_c\t$file_c\n";
  $seq_c++;
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
