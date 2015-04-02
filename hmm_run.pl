#!/usr/bin/perl
# Script:hmm_run.pl 
# Description: Generates a shell script to run batch searches using either hmmsearch or hmmscan
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.30.14
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
#####-----Global Variables-----#####
my $hmmfile = "";
my $dir = ".";
my $incE = 0;
my $abbr = "";
my $prog = "";
my $help = 0;
my $out = ".";
my ($fastafile,@fasta_files);
my $array;
GetOptions ('i|input=s'   => \$hmmfile, 
            'f|fasta=s'   => \$fastafile,
            'd|dir=s'     => \$dir,
            'e|eval=s'    => \$incE,
            't|type=s'    => \$abbr,
            'p|program=s' => \$prog,
            'h|help+'     => \$help,
            'o|out=s'     => \$out,
            'array'       => \$array);
my $usage = "Usage: hmm_run.pl -p hmmprogram -i hmmfile (-f fasta_file | -d proteome_dir) -e eval_threshold -t description [-o out_dir]\nCreates an executable shell script.\n";
die $usage if ($help);
#die "Can't open $fastafile: $!\n$usage" if (!(-e $fastafile));
die "Invalid hmmprogram: $prog\n\"hmmsearch\" or \"hmmscan\" only.\n$usage" if (($prog ne "hmmscan") and ($prog ne "hmmsearch"));
die "Please provide a description.\n$usage" if ($abbr eq "");
die "Invalid hmm profile: $hmmfile\n$usage" if ($hmmfile eq "");

#####-----Main-----#####
## Create the shell script
#print $hmmfile,"\n";
open(OUT,">","$out/$abbr\_$prog.sh");
if(!$fastafile)
{
  opendir(DIR,$dir);
  @fasta_files = grep {/\.fasta$/} readdir(DIR);
  closedir(DIR);
}
else
{
  my @ff = split(/\//,$fastafile);
  $fastafile = pop @ff;
  $dir = join("/",@ff);
  push @fasta_files,$fastafile;
}
#print OUT "cd ",cwd(),"\n";
print OUT "#PBS -l nodes=1:ppn=1 -o $abbr.log -j oe\n\n";
print OUT 'N=$PBS_ARRAYID
if [ ! $N ]; then
  echo "No ARRAYID"
  exit 
fi',"\n\n";
print OUT 'QUERY="',$hmmfile,'"
TYPE="',$abbr,'"
PROTDIR="',$dir,'"
FILELIST="$PROTDIR/proteomelist"
LINE=`head -n $N $FILELIST | tail -n 1`
ORG=`head -n $N $FILELIST | tail -n 1 | cut -d"_" -f 1`',"\n\n";

my $outfilename;
if($prog eq "hmmscan")
{
  $outfilename = '$ORG-vs-$TYPE';
} #hmmscan
else
{
  $outfilename = '$TYPE-vs-$ORG'; #join("-",$abbr,"vs",substr($fasta_file,0,4));
} #hmmsearch
print OUT "$prog ";
print OUT "--noali ";
if($incE){print OUT "--incE $incE -E $incE ";}
print OUT "--tblout ",join("\\_",$outfilename,"tbl"),".$prog ";
print OUT "-o $outfilename\.$prog ";
print OUT '$QUERY '; #$hmmfile ";  
print OUT '$PROTDIR/$LINE';#"$dir/$fasta_file";
print OUT "\n";
close(OUT);
print `chmod 744 $out/$abbr\_$prog.sh`;

warn "Done.\n";
exit(0);
