#!/usr/bin/perl -w
# Script: unalign.pl
# Description: Un-aligns a fasta-formatted alignment
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 6.23.11
####################
# Usage: unalign.pl alignfile
####################

use strict;
use Bio::Seq;
use Bio::SeqIO;

my $infile = $ARGV[0];
my @infilename = split(/\./,$infile);
my $name = $infilename[0];
print $name,"\n";
if(scalar(@infilename) > 2)
{
  pop(@infilename);
  $name = join(".",@infilename);
  print $name,"\n";
}


my $alignmentfile = new Bio::SeqIO(-file=>$infile, -format=>'fasta');


while (my $seq = $alignmentfile->next_seq)
{   
  #print $seq->seq(),"\n";
  my $dealseq = $seq->seq();
  $dealseq =~ s/-//g;
  $seq->seq($dealseq);
  #print $seq->seq(),"\n";
  my $dealignmentfile = new Bio::SeqIO(-file=>">>$name\_unal.fa", -format=>'fasta');
  $dealignmentfile->write_seq($seq);
}
