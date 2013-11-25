#!/usr/bin/perl
# Script: fasta2hmm.pl
# Description: Pipeline for converting unaligned fasta files to hmm files
# Author: Steven Ahrendt
# email: sarhrendt0@gmail.com
# Date: 1.22.13
#######################################
# Cluster w/ uclust at 85%
# Align w/ Tcoffee
# Convert from Clustalw to aligned Fasta
# Build HMM
#######################################
# Usage: perl fasta2hmm.pl fastafile [-c] [-s]
#######################################
use strict;
use warnings;
use Getopt::Long;
use Cwd;

my $input;
my $shell; # Make a shell script instead of running
my ($help,$verb,$clust);

GetOptions ('i|input=s' => \$input,
            'h|help'    => \$help,
            'v|verbose' => \$verb,
            'c|cluster' => \$clust,
            's|shell'   => \$shell);

my $usage = "Usage: perl fasta2hmm.pl -i fastafile [-c] [-s]\n";
die $usage if $help;
die "No input file: $!\n$usage" if (!$input);

my $fasta = $input;
my $fasta_name = (split(/\./,$fasta))[0];
print $fasta,"\n";

## Display Steps
my $tc_in = $fasta;
if($shell)
{
  open(SH,">fas2hmm.sh");
  print SH "cd ",cwd(),"\n";
  if($clust)
  {
    $tc_in = "$fasta_name\.cluster";
    print SH "usearch -cluster_fast $fasta -id 0.85 -centroids $tc_in\n";
  }
  print SH "t_coffee $tc_in -n_core=4 -output=fasta_aln\n";
  print SH "hmmbuild --cpu 4 --informat afa $fasta_name.hmm $fasta_name\.fasta_aln\n";
  close(SH);
  print `chmod 744 fas2hmm.sh`;
}
else
{
  ## Run Steps
  if($clust)
  {
    print `usearch -cluster_fast $fasta -id 0.85 -centroids $tc_in`;
  }
  print `t_coffee $tc_in -n_core=4 -output=fasta_aln`;
  print `hmmbuild --cpu 4 --informat afa $fasta_name.hmm $fasta_name\.fasta_aln`;
}
