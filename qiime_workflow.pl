#!/usr/bin/perl
# Script: /rhome/sahrendt/Scripts/qiime_workflow.pl
# Description: Generate shell scripts for processing qiime Amend2009 files w/ UNITE db 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.09.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Cwd;

#####-----Global Variables-----#####
my $REGS = 7;
my $PWD = getcwd;
my ($help,$verb);

GetOptions( 'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: /rhome/sahrendt/Scripts/qiime_workflow.pl\n";
die $usage if $help;

#####-----Main-----#####
for(my $r=1;$r<=$REGS;$r++)
{
  next if($r == 2);
  open(my $sh, ">", "qiime_AmendUNITE_reg$r\.sh");
  loadModules($sh);
  print $sh "pick_otus.py -i reg$r\_split_libraries/seqs.fna -o reg$r\_otus/\n";
  print $sh "rename 's/seqs/reg$r\_seqs/' reg$r\_otus/seqs*\n";
  print $sh "pick_rep_set.py -i reg$r\_otus/reg$r\_seqs_otus.txt -f ./reg$r\_split_libraries/seqs.fna -l reg$r\_otus/reg$r\_seqs_rep_set.log -o reg$r\_otus/reg$r\_seqs_rep_set.fasta\n";
  print $sh "align_seqs.py -i reg$r\_otus/reg$r\_seqs_rep_set.fasta -m muscle -o reg$r\_otus/muscle_alignment/\n";
  print $sh "ln -s /srv/projects/db/QIIME/UNITE_2014-02-09/sh_refs_qiime_ver6_99_09.02.2014.fasta ./reg$r\_otus/UNITE_ver6_99_09_02_2014.fna\n";
  print $sh "ln -s $PWD/UNITE_ver6_99_09_02_2014.txt ./reg$r\_otus/UNITE_ver6_99_09_02_2014.txt\n";
  print $sh "assign_taxonomy.py -i reg$r\_otus/reg$r\_seqs_rep_set.fasta -r reg$r\_otus/UNITE_ver6_99_09_02_2014.fna -t reg$r\_otus/UNITE_ver6_99_09_02_2014.txt -o reg$r\_otus/UNITE_taxonomy --rdp_max_memory 12000\n";
  print $sh "filter_alignment.py -i reg$r\_otus/muscle_alignment/reg$r\_seqs_rep_set_aligned.fasta -o reg$r\_otus/muscle_alignment_filtered --suppress_lane_mask_filter\n";
  print $sh "mkdir reg$r\_otus/fasttree_phylogeny\n";
  print $sh "make_phylogeny.py -i reg$r\_otus/muscle_alignment_filtered/reg$r\_seqs_rep_set_aligned_pfiltered.fasta -o reg$r\_otus/fasttree_phylogeny/reg$r\_seqs_rep_set_aligned_pfiltered.tre -l reg$r\_otus/fasttree_phylogeny/reg$r\_seqs_rep_set_aligned_pfiltered.log\n";
  print $sh "make_otu_table.py -i reg$r\_otus/reg$r\_seqs_otus.txt -t reg$r\_otus/UNITE_taxonomy/reg$r\_seqs_rep_set_tax_assignments.txt -o reg$r\_otus/reg$r\_seqs_otu_table.biom\n";
  close($sh);
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
