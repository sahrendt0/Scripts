#!/usr/bin/perl
# Script: secretome_workflow.pl
# Description: Runs through a series of programs for secretome prediction in Fungi 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.16.2014
##################################
# Program order:
#  signalp
#  tmhmm (only keep those with no TM prediction
#  WolfPSORT
#  Phobius
#  PS-SCAN
#####################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my $scripts_dir = "/rhome/sahrendt/Scripts";
my $prot_dir = "/rhome/sahrendt/bigdata/Genomes/Protein";
my $prosite_data = "/rhome/sahrendt/bigdata/Data/Prosite/prosite.dat";
my $prot_file;
my ($sigp_res,$tm_res,$wolfp_res,$phobius_res,$pscan_res);
my @chytrids = qw(Amac Bden Cang Gpro Hpol OrpC PirE Psoj Rall Spun);
my $fungi;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'fungi=s'   => \$fungi,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: secretome_workflow.pl [--fungi a,b,c...]\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
if($fungi)
{
  foreach my $item (split(/,/,$fungi))
  {
    push (@chytrids,$item);
  }
}
foreach my $org (@chytrids)
{
  open(my $sh,">","$org\_secretome.sh");
  print $sh "# Modules\n";
  loadModules($sh);
  $sigp_res = "signalp";
  $tm_res = "noTM";
  $wolfp_res = "wolfPSort";
  $phobius_res = "phobius";
  $pscan_res = "psScan";
  $prot_file = "$org\_proteins.aa.fasta";
  print $sh "mkdir $org\n";
  print $sh "cd $org\n";
  print $sh "ln -s $prot_dir/$prot_file\n";

  # SignalP
  $sigp_res = join(".","$org\_proteins",$sigp_res);
  print $sh "# SignalP\n";
  print $sh "signalp $prot_file > $sigp_res\n";
  print $sh "grep \"#\" -v $sigp_res | grep \"Y\" | cut -f 1 -d\" \" > $sigp_res\.accnos\n";
  print $sh "$scripts_dir/getseqfromfile.pl -f $prot_file -a $sigp_res\.accnos > $sigp_res\.aa.fasta\n";
  
  # TMHMM
  print $sh "# TMHMM\n";
  $tm_res = join(".",$sigp_res,$tm_res);
  print $sh "/rhome/sahrendt/bin/tmhmm-2.0c/bin/tmhmm -short $sigp_res.aa.fasta > $sigp_res\.tmhmm\n";
  print $sh "grep \"PredHel=0\" $sigp_res\.tmhmm | cut -f 1 > $tm_res\.accnos\n";
  print $sh "$scripts_dir/getseqfromfile.pl -f $prot_file -a $tm_res\.accnos > $tm_res\.aa.fasta\n";

  # WolfPSORT
  print $sh "# WolfPSORT\n";
  $wolfp_res = join(".",$tm_res,$wolfp_res);
  print $sh "runWolfPsortSummary fungi < $tm_res\.aa.fasta > $wolfp_res\n";
  print $sh "$scripts_dir/Inhibition_scripts/parseWolfPSORT.pl -i $wolfp_res | cut -f 1 > $wolfp_res\.accnos\n";
  print $sh "$scripts_dir/getseqfromfile.pl -f $prot_file -a $wolfp_res\.accnos > $wolfp_res\.aa.fasta\n";

  # Phobius
  print $sh "# Phobius\n";
  $phobius_res = join(".",$wolfp_res,$phobius_res);
  print $sh "/rhome/sahrendt/bin/phobius/phobius.pl -short $wolfp_res\.aa.fasta > $phobius_res\n";
  print $sh "grep \"0  Y\" $phobius_res | cut -f 1 -d\" \" > $phobius_res\.accnos\n";
  print $sh "$scripts_dir/getseqfromfile.pl -f $prot_file -a $phobius_res\.accnos > $phobius_res\.aa.fasta\n";

  # PScan
  print $sh "# PScan\n";
  $pscan_res = join(".",$phobius_res,$pscan_res);
  print $sh "/rhome/sahrendt/bin/ps_scan/ps_scan.pl -o pff -s --pfscan /rhome/sahrendt/bin/ps_scan/pfscan --psa2msa /rhome/sahrendt/bin/ps_scan/psa2msa -d $prosite_data $phobius_res\.aa.fasta > $pscan_res\n";
  print $sh "cut -f 1 $pscan_res | sort | uniq > $pscan_res\.accnos\n";
  print $sh "$scripts_dir/getseqfromfile.pl -f $prot_file -a $pscan_res\.accnos > $pscan_res\.aa.fasta\n";
  close($sh);
  print `chmod 744 $org\_secretome.sh`;
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub loadModules
{
  my $fh = shift @_;
  print $fh "module load wolfpsort\n";
  print $fh "module load signalp/4.1\n";
  print $fh "module load tmhmm\n";
}
