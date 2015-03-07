#!/usr/bin/perl
# Script: seqtranslate.pl
# Description: Simple script to translate a sequence 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 02.25.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: seqtranslate.pl -i input\nSimple script to translate a sequence\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $seqin_obj = Bio::SeqIO->new(-file => "<$input",
                                -format => "fasta");
my $seqout_obj = Bio::SeqIO->new(-fh => \*STDOUT,
                                 -format => "fasta");

while (my $seq_obj = $seqin_obj->next_seq)
{
  $seqout_obj->write_seq($seq_obj->translate);
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
