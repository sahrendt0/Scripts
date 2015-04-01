#!/usr/bin/perl
# Script: pdb2fasta.pl
# Description: Gets fasta sequence from pdb file
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.03.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use lib '/home/sahrendt/Scripts';
use lib '/rhome/sahrendt/Scripts/pdb_scripts';
use lib '/home/sahrendt/Scripts/pdb_scripts';
use ParsePDB;
use PDBAnalysis;
#use SeqAnalysis;
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: pdb2fasta.pl -i input\nGets fasta sequence from pdb file\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $seq_obj = getSeqFromFile($input);
my $seqio_obj = Bio::SeqIO->new(-format => "fasta",
                                -file => ">$input.faa");

$seqio_obj->write_seq($seq_obj);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
