#!/usr/bin/perl
# Script: splitup.pl
# Description: splits each sequence of a single multi-sequence fasta file into multiple single-sequence fasta files
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 09.23.2011
############################
## ** bp_dpsplit.pl is standard bioperl implementation
####################################
use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

#####-----Global Variables-----#####
my $input;
my $size = 1;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            's|size=s'  => \$size,
            'h|help'    => \$help,
            'v|verbose' => \$verb);

my $usage = "Usage: splitup.pl -i fastafile [-s size]\nOutput to directory containing files\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $input_db = Bio::SeqIO->new(-file => $input, 
                               -format => 'fasta');
my $seq_no = 0;  # counter for number of seqs written to a specific file
my $file_no = 0; # counter for file being written to
my $outdir = "$input\_files/";

system("mkdir $outdir");
my @tmp = split(/\./,$input);
my $ext = pop @tmp;
my $filename = join(".",@tmp);

while(my $seq_obj = $input_db->next_seq)
{
  my $ofilename = join(".",$filename,$file_no,$ext);
  $ofilename = join("",$outdir,$ofilename);
  my $outfile = Bio::SeqIO->new(-file => ">>$ofilename",
                                -format => 'fasta');
  $outfile->write_seq($seq_obj);
  $seq_no++;
  if($seq_no >= $size)
  {
    $file_no++;
    $seq_no = 0;
  }  
}


#$seqio_obj->write_seq($seq_obj);
