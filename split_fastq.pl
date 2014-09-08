#!/usr/bin/perl
# Script: split_fastq.pl
# Description: Splits a fastq file into a fasta and a qual file
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 9.8.14
#####################################
# Usage: split_fastq.pl -i fastqfile
#####################################
use warnings;
use strict;
use Bio::Perl;
use Getopt::Long;

#####-----Global Variables-----######
my $input;
my ($help,$verb);
GetOptions ('i|input=s' => \$input,
            'h|help'    => \$help,
            'v|verbose' => \$verb);

my $usage = "Usage: split_fastq.pl -i fastqfile\n";
die $usage if ($help);
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $fastqfile = $input;

my $sampleID = (split(/\./, $fastqfile))[0];

my $fastafile = "$sampleID\.fna";
my $qualfile = "$sampleID\.qual";

my $in=Bio::SeqIO->new(-file=>$fastqfile,-format=>"fastq");
my $seqOut=Bio::SeqIO->new(-file=>">$fastafile",-format=>"fasta");
my $qualOut=Bio::SeqIO->new(-file=>">$qualfile",-format=>"qual");
while(my $seq=$in->next_seq)
{
  $seqOut->write_seq($seq);
  $qualOut->write_seq($seq);
}

warn "Done.\n"
exit(0);

#####-----Subroutines-----#####
