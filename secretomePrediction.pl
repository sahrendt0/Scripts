#!/usr/bin/perl
# Script: secretomePrediction.pl
# Description: Executes secretome workflow described by "Min et al. J Proteomics+Bioinformatics 2010" 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 09.18.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: secretomePrediction.pl -i input\nExecutes secretome workflow described by \"Min et al. J Proteomics+Bioinformatics 2010\"\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

print "# Modules\n";
print "module load wolfpsort\n";
print "module load signalp/4.1\n";
print "module load tmhmm\n";
print "mkdir $input\n";
print "cd $input\n";
print "ln -s /rhome/sahrendt/bigdata/Genomes/Protein/$input\_proteins.aa.fasta\n";
print "# SignalP\n";
print "signalp $input\_proteins.aa.fasta > $input\_proteins.signalp\n";
print "grep \"#\" -v $input\_proteins.signalp | grep \"Y\" | cut -f 1 -d\" \" > $input\_proteins.signalp.accnos\n";
print "/rhome/sahrendt/Scripts/getseqfromfile.pl -f $input\_proteins.aa.fasta -a $input\_proteins.signalp.accnos > $input\_proteins.signalp.aa.fasta\n";
print "# TMHMM\n";
print "/rhome/sahrendt/bin/tmhmm-2.0c/bin/tmhmm -short $input\_proteins.signalp.aa.fasta > $input\_proteins.signalp.tmhmm\n";
print "grep \"PredHel=0\" $input\_proteins.signalp.tmhmm | cut -f 1 > $input\_proteins.signalp.noTM.accnos\n";
print "/rhome/sahrendt/Scripts/getseqfromfile.pl -f $input\_proteins.aa.fasta -a $input\_proteins.signalp.noTM.accnos > $input\_proteins.signalp.noTM.aa.fasta\n";
print "# WolfPSORT\n";
print "runWolfPsortSummary fungi < $input\_proteins.signalp.noTM.aa.fasta > $input\_proteins.signalp.noTM.wolfPSort\n";
print "/rhome/sahrendt/Scripts/Inhibition_scripts/parseWolfPSORT.pl -i $input\_proteins.signalp.noTM.wolfPSort | cut -f 1 > $input\_proteins.signalp.noTM.wolfPSort.accnos\n";
print "/rhome/sahrendt/Scripts/getseqfromfile.pl -f $input\_proteins.aa.fasta -a $input\_proteins.signalp.noTM.wolfPSort.accnos > $input\_proteins.signalp.noTM.wolfPSort.aa.fasta\n";
print "# Phobius\n";
print "/rhome/sahrendt/bin/phobius/phobius.pl -short $input\_proteins.signalp.noTM.wolfPSort.aa.fasta > $input\_proteins.signalp.noTM.wolfPSort.phobius\n";
print "grep \"0  Y\" $input\_proteins.signalp.noTM.wolfPSort.phobius | cut -f 1 -d\" \" > $input\_proteins.signalp.noTM.wolfPSort.phobius.accnos\n";
print "/rhome/sahrendt/Scripts/getseqfromfile.pl -f $input\_proteins.aa.fasta -a $input\_proteins.signalp.noTM.wolfPSort.phobius.accnos > $input\_proteins.signalp.noTM.wolfPSort.phobius.aa.fasta\n";
print "# PScan\n";
print "/rhome/sahrendt/bin/ps_scan/ps_scan.pl -o pff -s --pfscan /rhome/sahrendt/bin/ps_scan/pfscan --psa2msa /rhome/sahrendt/bin/ps_scan/psa2msa -d /rhome/sahrendt/bigdata/Data/Prosite/prosite.dat $input\_proteins.signalp.noTM.wolfPSort.phobius.aa.fasta > $input\_proteins.signalp.noTM.wolfPSort.phobius.psScan\n";
print "cut -f 1 $input\_proteins.signalp.noTM.wolfPSort.phobius.psScan | sort | uniq > $input\_proteins.signalp.noTM.wolfPSort.phobius.psScan.accnos\n";
print "/rhome/sahrendt/Scripts/getseqfromfile.pl -f $input\_proteins.aa.fasta -a $input\_proteins.signalp.noTM.wolfPSort.phobius.psScan.accnos > $input\_proteins.signalp.noTM.wolfPSort.phobius.psScan.aa.fasta\n";

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
