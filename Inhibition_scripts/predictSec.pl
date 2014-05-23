#!/usr/bin/perl
# Script: predictSec.pl
# Description: Write shell scripts for hmmsearch for secretome 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.14.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my $curr_dir = "/rhome/sahrendt/bigdata/Inhibition/secretome/workflow";
my $hmmscript = "hmmsearch";
my $PFAM = "/rhome/sahrendt/bigdata/Data/HMM/PFAM_db/Pfam-A.hmm";
my $fasta_ext = "proteins.signalp.noTM.wolfPSort.phobius.psScan.aa.fasta";
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: predictSec.pl -i input\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
opendir(DIR,$curr_dir);
my @dirs = sort grep { -d && /\w+/ && $_} readdir(DIR);
closedir(DIR);
print "@dirs\n";

foreach my $dir (@dirs)
{
  opendir(DIR,"$curr_dir/$dir");
  print "mkdir $curr_dir/$dir/$hmmscript\n";
  print `mkdir $curr_dir/$dir/$hmmscript`;
  print "hmm_run.pl -p $hmmscript -i $PFAM -f $curr_dir/$dir/$dir\_$fasta_ext -e 1e-10 -t PFAM10 -o $curr_dir/$dir/$hmmscript\n";
  print `hmm_run.pl -p $hmmscript -i $PFAM -f $curr_dir/$dir/$dir\_$fasta_ext -e 1e-10 -t PFAM10 -o $curr_dir/$dir/$hmmscript`;
  print "qsub -d $curr_dir/$dir/$hmmscript -l nodes=1:ppn=4 $curr_dir/$dir/$hmmscript/PFAM10_hmmsearch.sh\n";
  print `qsub -d $curr_dir/$dir/$hmmscript -l nodes=1:ppn=4 $curr_dir/$dir/$hmmscript/PFAM10_hmmsearch.sh`;
  closedir(DIR);
}


warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
