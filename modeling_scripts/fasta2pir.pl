#!/usr/bin/perl 
# Description: Converts fasta to PIR format (for Modeller)

use warnings;
use strict;
use Bio::SeqIO;
use Bio::Seq;

my $infile = shift;
my $name = (split(/\./,$infile))[0];

my $SeqIO = Bio::SeqIO->new(-file   => $infile,
                            -format => "fasta");

my $outfile = join(".",$name,"ali");

open(PIR,">$outfile");
print PIR ">P1;";
print PIR "$name\n";
print PIR "sequence:",$name,":::::::0.00: 0.00\n";
print PIR $SeqIO->next_seq->seq();
close(PIR);
