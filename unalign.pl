#!/usr/bin/perl -w
# Script: unalign.pl
# Description: Un-aligns a fasta-formatted alignment
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 6.23.11
####################
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'    => \$help,
            'v|verbose' => \$verb);
my $usage = "unalign.pl -i alignfile\nUn-aligns a fasta-formatted alignment\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $name = getName($input);

my $alignmentfile = new Bio::SeqIO(-file=>$input, 
                                   -format=>'fasta');

while (my $seq = $alignmentfile->next_seq)
{   
  my $dealseq = $seq->seq();
  $dealseq =~ s/-//g;
  $dealseq =~ s/\.//g;
  $seq->seq($dealseq);
  my $dealignmentfile = new Bio::SeqIO(-file=>">>$name\_unal.fa", 
                                       -format=>'fasta');
  $dealignmentfile->write_seq($seq);
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getName {
  my $in = shift @_;
  my @infilename = split(/\./,$in);
  my $name = $infilename[0];
  if(scalar(@infilename) > 2)
  {
    pop(@infilename);
    $name = join(".",@infilename);
  }
}
