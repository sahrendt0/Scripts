#!/usr/bin/perl
# Script: /rhome/sahrendt/Scripts/qiime_workflow.pl
# Description: Generate shell scripts for processing qiime Amazon_air files w/ UNITE db 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.03.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Cwd;

#####-----Global Variables-----#####
#my $REGS = 7;
my $PWD = getcwd;
my $dataset = "Amazon";
my $db = "UNITE";
my @regs = qw(R1_11META R1_8META R1_9META R2_11META R2_8META R2_9META);
my ($help,$verb);

GetOptions( 'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: /rhome/sahrendt/Scripts/qiime_workflow.pl\n";
die $usage if $help;

#####-----Main-----#####
foreach my $reg (@regs)
{
  my $sh_file = "qiime_$dataset\_$db\_$reg\.sh";
  open(my $sh, ">", $sh_file);
  loadModules($sh);
  print $sh "pick_otus.py -i $reg/$reg\_final.fasta -o $reg\_otus/\n";
  print $sh "rename 's/seqs/$reg\_seqs/' $reg\_otus/seqs*\n";
  print $sh "pick_rep_set.py -i $reg\_otus/$reg\_seqs_otus.txt -f ./$reg/$reg\_final.fasta -l $reg\_otus/$reg\_seqs_rep_set.log -o $reg\_otus/$reg\_seqs_rep_set.fasta\n";
  print $sh "align_seqs.py -i $reg\_otus/$reg\_seqs_rep_set.fasta -m muscle -o $reg\_otus/muscle_alignment/\n";
  print $sh "ln -s /srv/projects/db/QIIME/UNITE_2014-02-09/sh_refs_qiime_ver6_99_09.02.2014.fasta ./$reg\_otus/UNITE_ver6_99_09_02_2014.fna\n";
  print $sh "ln -s $PWD/UNITE_ver6_99_09_02_2014.txt ./$reg\_otus/UNITE_ver6_99_09_02_2014.txt\n";
  print $sh "assign_taxonomy.py -i $reg\_otus/$reg\_seqs_rep_set.fasta -r $reg\_otus/UNITE_ver6_99_09_02_2014.fna -t $reg\_otus/UNITE_ver6_99_09_02_2014.txt -o $reg\_otus/UNITE_taxonomy --rdp_max_memory 12000\n";
  print $sh "filter_alignment.py -i $reg\_otus/muscle_alignment/$reg\_seqs_rep_set_aligned.fasta -o $reg\_otus/muscle_alignment_filtered --suppress_lane_mask_filter\n";
  print $sh "mkdir $reg\_otus/fasttree_phylogeny\n";
  print $sh "make_phylogeny.py -i $reg\_otus/muscle_alignment_filtered/$reg\_seqs_rep_set_aligned_pfiltered.fasta -o $reg\_otus/fasttree_phylogeny/$reg\_seqs_rep_set_aligned_pfiltered.tre -l $reg\_otus/fasttree_phylogeny/$reg\_seqs_rep_set_aligned_pfiltered.log\n";
  print $sh "make_otu_table.py -i $reg\_otus/$reg\_seqs_otus.txt -t $reg\_otus/UNITE_taxonomy/$reg\_seqs_rep_set_tax_assignments.txt -o $reg\_otus/$reg\_seqs_otu_table.biom\n";
  close($sh);
  print `chmod 744 $sh_file`;
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub loadModules
{
  my $fh = shift @_;
  print $fh "module load qiime\n";
  print $fh "module load ncbi-blast\n";
  print $fh "module load FastTree\n";
}

