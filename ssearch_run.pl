#!/usr/bin/perl
# Script: ssearch_run.pl
# Description: Generates batch shell script for ssearches
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.6.13
########################
# Usage: perl ssearch_run.pl -f fasta_file -t abbr [-e eval]
########################

use warnings;
use strict;
use Cwd;
use Getopt::Long;

my $help = 0;
my $fasta_file;
my $abbr;
my $eval = 0.1;
my $gdir = "/rhome/sahrendt/Data/genomes/pep/";
my $cwd = getcwd();

GetOptions ('f|fasta=s' => \$fasta_file,
            't|type=s'  => \$abbr,
            'e|eval=s'  => \$eval,
            'h|help+'   => \$help);


if($help)
{
  print "Usage: perl ssearch_run.pl -f fasta_file -t abbr [-e eval]\n";
  exit;
}

opendir(DIR,$gdir);
my @prots = grep {/\.fasta$/} readdir(DIR);
closedir(DIR);

if(($fasta_file) && ($abbr))
{
  open(TEST,"<$fasta_file") || die "Can't open $fasta_file\n";
  close(TEST);
  print "cd $cwd\n";
  foreach my $file (@prots)
  {
    print "ssearch36 "; # Script
    print "-S "; # filter lowercase residues 
    print "-m 8C "; # output format: Blast, tabular
    print "-E $eval "; # e-val cutoff
    print "-k 10000 "; # num of shuffles
    print "./$fasta_file $gdir/$file > $abbr-vs-",substr($file,0,4),".ssearch\n";
  }
}
else
{
  print "Usage: perl ssearch_run.pl fasta_file abbr\n";
}
