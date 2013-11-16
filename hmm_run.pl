#!/usr/bin/perl
# Script:hmm_run.pl 
# Description: Generates a shell script to run batch searches using either hmmsearch or hmmscan
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 4.11.13
####################################
# Usage: perl hmm_run.pl -p hmmprogram -i hmmfile -d directory_of_proteomes -e inclusion_eval_threshold -t description
#####################################
# -t   = GA (G-alpha)
#        Gfu (Fungal G-alpha)
#        7tm
# -p   = hmmsearch
#      = hmmscan
#################

use strict;
use warnings;
use Getopt::Long;
use Cwd;

my $hmmfile = "";
my $dir = ".";
my $incE = 0;
my $abbr = "";
my $prog = "";
my $help = 0;
#GetOptions ('verbose'    => \$verbose, 'all' => \$all);
GetOptions ('i|input=s'   => \$hmmfile, 
            'd|dir=s'     => \$dir,
            'e|eval=s'    => \$incE,
            't|type=s'    => \$abbr,
            'p|program=s' => \$prog,
            'h|help+'     => \$help);

if($help)
{
  print "Usage: hmm_run.pl -p hmmprogram -i hmmfile -d proteome_dir -e eval_threshold -t description\n";
  exit;
}

## Create the shell script
#print $hmmfile,"\n";
open(OUT,">","$abbr\_$prog.sh");
if(($hmmfile ne "") && ($abbr ne "") && (($prog eq "hmmscan") || ($prog eq "hmmsearch")))
{
  opendir(DIR,$dir);
  my @fasta_files = grep {/\.fasta$/} readdir(DIR);
  closedir(DIR);
  print OUT "cd ",cwd(),"\n";  
  foreach my $fasta_file (@fasta_files)
  {
    my $outfilename;
    if($prog eq "hmmscan")
    {
      $outfilename = join("-",substr($fasta_file,0,4),"vs",$abbr);
    } #hmmscan
    else
    {
      $outfilename = join("-",$abbr,"vs",substr($fasta_file,0,4));
    } #hmmsearch
    print OUT "$prog ";
    print OUT "--noali ";
    if($incE){print OUT "--incE $incE -E $incE ";}
    print OUT "--tblout ",join("_",$outfilename,"tbl"),".$prog ";
    print OUT "-o $outfilename\.$prog ";
    print OUT "$hmmfile ";  
    print OUT "$dir/$fasta_file";

#    print " > ";
#    print $abbr;
#    print "-vs-",substr($fasta_file,0,3),".$prog";
    print OUT "\n";
  }
close(OUT);
print `chmod 744 $abbr\_$prog.sh`;
}
else
{
  print "Please provide a vaild hmm profile, a valid hmmprogram (hmmsearch or hmmscan), and a valid search description\n";
  print " Usage: perl hmm_run.pl -p hmmprogram -i hmmfile -d directory_of_proteomes -e inclusion_eval_threshold -t description\n";
}

