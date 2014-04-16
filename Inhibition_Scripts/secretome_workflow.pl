#!/usr/bin/perl
# Script: secretome_workflow.pl
# Description: Runs through a series of programs for secretome prediction in Fungi 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.16.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my $prot_dir = "/rhome/sahrendt/bigdata/Genomes/Protein/";
my @chytrids = qw(Amac Bden Cang Gpro Hpol OrpC PirE Psoj Rall Spun);
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: secretome_workflow.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub loadModules
{
  my $fh = shift @_;
  print $fh "module load wolfpsort\n";
  print $fh "module load signalp\n";
  print $fh "module load tmhmm\n";
}
