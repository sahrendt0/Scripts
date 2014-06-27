#!/usr/bin/perl 
# Script: model_all.pl
# Description: Generates a modeller script based on inputs
#########################
# Usage: model_all.pl -n 4letter_name -p IDcode
#####

use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
use Getopt::Long;

my ($name,$code);
my $parsed;
my ($seqnames,$alifile);
my $help = 0;
GetOptions ("n|name=s" => \$name,
            "p|pdbcode=s" => \$code,
            "s|seqname=s" => \$seqnames,
            "a|alifile=s" => \$alifile,
            "h|help+" => \$help);

if($help)
{
  print "Usage: model_all.pl -n 4letter_name -p IDcode -s accnosfile -a alifile\n";
  exit;
}

#my $dir = ".";
#opendir(DIR,$dir);
#my @files = grep { /\.ali$/ } readdir(DIR); 
#closedir(DIR);
#print @files,"\n";

open(SEQNAMES,"<$seqnames");
my $ccode = join("",$code,"A");
foreach my $parsed (<SEQNAMES>)
{
  #my $file = (split(/\./,$filename))[0];
  #print $file,"\n";
  #my $pir_in = Bio::SeqIO->new(-file => $filename,                               -format => "pir");
  #my $seq = $pir_in->next_seq;
  #my $parsed = $seq->display_id;
  #print $parsed,"\n";
  chomp $parsed;
  open(SCRIPT,">$parsed\_$code\.py");
  print SCRIPT "from modeller import \*\n";
  print SCRIPT "from modeller.automodel import *\n";
  print SCRIPT "\n";
  print SCRIPT "env = environ()\n";
  print SCRIPT "a = automodel(env,\n";
  print SCRIPT "              alnfile='$alifile',\n";
  print SCRIPT "              knowns='$name\|$code',\n";
  print SCRIPT "              sequence='$parsed',\n";
  print SCRIPT "              assess_methods=assess.DOPE)\n";
  print SCRIPT "a.starting_model = 1\n";
  print SCRIPT "a.ending_model = 8\n";
  print SCRIPT "a.make()\n";
  close(SCRIPT);
}
close(SEQNAMES);
__END__
  print `mkdir $file`;
  chdir($file) or die "Can't chdir to $file\n";
  print `ln -s ../$code.pdb ./$code.pdb`;
  print `mv ../$filename .`;
  print `mv ../model_single.py .`;
  print `mod9.9 model_single.py`;
  print `mv model_single.log $file\.log`;
  chdir("..") or die "Can't chdir to \"..\"\n";
}
