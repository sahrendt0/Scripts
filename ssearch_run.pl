#!/usr/bin/perl
# Script: ssearch_run.pl
# Description: Generates batch shell script for ssearches
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.6.13
########################
# Usage: perl ssearch_run.pl -f fasta_file -t abbr [-e eval] [-Z db_size] [-T threads]
########################

use warnings;
use strict;
use Cwd;
use Getopt::Long qw(:config no_ignore_case);

my $help = 0;
my $fasta_file;
my $abbr;
my $eval = 0.1;
my $align;
my $gdir = "/rhome/sahrendt/bigdata/Genomes/Protein/";
my $cwd = getcwd();
my $db_size;
my $threads;

GetOptions ('f|fasta=s' => \$fasta_file,
            't|type=s'  => \$abbr,
            'e|eval=s'  => \$eval,
            'h|help+'   => \$help,
            'Z|Z=s'	=> \$db_size,
            'align'     => \$align,
            'T|T=s'     => \$threads);

my $usage = "Usage: perl ssearch_run.pl -f fasta_file -t abbr [-e eval]  [-Z db_size] [-T threads] [--align]\n";
$usage .= "Single use: ssearch36_t -T threads -S -m 8C -E eval -k 10000 -Z db_size query_file db_file > output\n";
die $usage if ($help);
die $usage if (!$fasta_file);

opendir(DIR,$gdir);
my @prots = grep {/\.fasta$/} readdir(DIR);
closedir(DIR);

if($align){$abbr .= "aln";}
open(OUT,">$abbr\_ssearch.sh");
if(($fasta_file) && ($abbr))
{
  open(TEST,"<$fasta_file") || die "Can't open $fasta_file\n";
  close(TEST);
  foreach my $file (@prots)
  {
    print OUT "ssearch36"; # Script
    if($threads){print OUT "_t -T $threads";}
    print OUT " -S "; # filter lowercase residues 
    if(!$align){print OUT "-m 8C ";} # output format: Blast, tabular
    print OUT "-E $eval "; # e-val cutoff
    print OUT "-k 10000 "; # num of shuffles
    if($db_size){print OUT "-Z $db_size ";}
    print OUT "$fasta_file $gdir/$file > $abbr-vs-",substr($file,0,4),".ssearch\n";
  }
  print `chmod 744 $abbr\_ssearch.sh`;
}
else
{
  print "Usage: perl ssearch_run.pl fasta_file abbr\n";
}
close(OUT);
