#!/usr/bin/perl 
# Script: model_all_align.pl
# Description: Generates scripts to align all experimental sequences
# Author: Steven Ahrendt
# Date: 9.12.13
##########################
# Usage: model_align_all.pl -i pirfile -p pdbcode
##########################

use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

my $help=0;
my $input;
my $outfile = "align2d.py";
my $pdbcode;# = "2R4R";
my $chain = "A";
my $pirfile;

GetOptions ("i|infile=s" => \$pirfile,
            "p|pdb=s" => \$pdbcode,
            "h|help+" => \$help);

if($help)
{
  print "Usage: model_align_all.pl -i pirfile -p pdbcode\n";
  exit;
}

if(length($pdbcode) != 4)
{
  print "Error: use only 4-character pdbcode\n";
  exit;
}

## Generate align2d.py

my $pir_in = Bio::SeqIO->new(-file => $pirfile,
                             -format => "pir");
my $parsed = $pir_in->next_seq->display_id;
my $pchain = join("",$pdbcode,$chain);
open(AL,">$outfile");
print AL "from modeller import *\n";
print AL "env = environ()\n";
print AL "aln = alignment(env)\n";
print AL "mdl = model(env,\n";
print AL "            file='$pdbcode',\n";
print AL "            model_segment=('FIRST:$chain','LAST:$chain'))\n";
print AL "aln.append_model(mdl,\n";
print AL "                 align_codes='$pchain',\n";
print AL "                 atom_files='$pdbcode\.pdb')\n";
print AL "aln.append(file='$pirfile',\n";
print AL "           align_codes='$parsed')\n";
print AL "aln.align2d()\n";
print AL "aln.write(file='$parsed\_$pdbcode\.ali',\n";
print AL "          alignment_format='PIR')\n";
print AL "aln.write(file='$parsed\_$pdbcode\.pap',\n";
print AL "          alignment_format='PAP')\n";
close(AL);
