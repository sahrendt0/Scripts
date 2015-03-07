#!/usr/bin/perl
# Script: getseqFragment.pl
# Description: Returns a sequence fragment; fasta format 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.05.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $input;
my $range;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'range=s'   => \$range,  # comma-delim'd string
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getseqFragment.pl -i input --range a-b,[c-d]\nReturns a sequence fragment; fasta format\nRanges are specified in \"a-b[,c-d]\" format\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my @ranges = split(/,/,$range);
my $seqin_obj = Bio::SeqIO->new(-file => $input,
                                -format => "fasta");
my $seqout_obj = Bio::SeqIO->new(-fh     => \*STDOUT,
                                 -format => "fasta");

while(my $seq_obj = $seqin_obj->next_seq)
{
  foreach my $r (@ranges)
  {
    my ($start,$end) = split(/-/,$r);
    my $new_seq = Bio::Seq->new(-display_id => join("|",$seq_obj->display_id,$r),
                                -seq => $seq_obj->subseq($start,$end));
    $seqout_obj->write_seq($new_seq);
  }
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
