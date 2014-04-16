#!/usr/bin/perl
# Script: /rhome/sahrendt/Scripts/qiime_workflow.pl
# Description: Generate shell scripts for processing qiime general workflow 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.10.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Cwd;

#####-----Global Variables-----#####
#my $REGS = 7;
my $PWD = getcwd;
my $dataset;
my ($db,@db_fasta,@db_tax);
my %db_path = ("UNITE" => "/rhome/sahrendt/bigdata/Built_Env/dbs/UNITE",
                "KS"    => "/rhome/sahrendt/bigdata/Built_Env/dbs/Seifert_ITS_refdb");
my @DB_OPTIONS = keys(%db_path);
my @regs;
my $RR;
my $version = "1.6.0-dev";
my ($help,$verb);

GetOptions( 'dataset=s'  => \$dataset,
            'database=s' => \$db,
            'rr'       => \$RR,  # set to use "random removed" database
            'version=s'   => \$version,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: qiime_workflow_general.pl --database database --dataset dataset [--version]\n";
die $usage if $help;
die "No dataset.\n$usage" if !$dataset;
die "No database.\n$usage" if !$db;
die "Unknown database: \"$db\".\nOptions: @DB_OPTIONS\n$usage" if (!exists $db_path{$db});
#####-----Main-----#####
opendir(DIR,$PWD);
@regs = grep {-l "$PWD/$_"} readdir(DIR);
closedir(DIR);

print "$db_path{$db}\n" if $verb;
opendir(DB,$db_path{$db});
@db_fasta = sort (grep { /$db.{0,3}\.aa\.fasta$/ } readdir(DB));
closedir(DB);
print "@db_fasta\n" if $verb;

opendir(DB,$db_path{$db});
@db_tax = sort (grep { /$db.{0,3}\.tax$/ } readdir(DB));
closedir(DB);
print "@db_tax\n" if $verb;

my $ind = 0; # index of fasta / taxonomy file to use
             # b/c of sorting, random removed (RR) version will always be index = 1 
if($RR)
{
  $ind = 1;
}

foreach my $reg (@regs)
{
  print $reg,"\n" if $verb;
  my $sh_file = "qiime_$dataset\_$db\_$reg\.sh";
  opendir(REG,$reg);
  my @fasta = grep { /\.f.+$/ } readdir(REG);
  closedir(REG);
  my $orig_fasta = shift @fasta;
  my $prefix = (split(/\./,$orig_fasta))[0];
  open(my $sh, ">", $sh_file);
  loadModules($sh);
  print $sh "pick_otus.py -i $reg/$orig_fasta -o $reg\_otus/\n";
  if(($dataset eq "Amend") or ($dataset eq "Kinney"))
  {
    $prefix = join("_",(split(/\_/,$reg))[0],$prefix) if ($dataset eq "Amend");
    $prefix = $reg if ($dataset eq "Kinney");
    print $sh "rename 's/seqs/$prefix\/' $reg\_otus/seqs*\n";
  }
  print $sh "pick_rep_set.py -i $reg\_otus/$prefix\_otus.txt -f ./$reg/$orig_fasta -l $reg\_otus/$prefix\_rep_set.log -o $reg\_otus/$prefix\_rep_set.fasta\n";
  print $sh "align_seqs.py -i $reg\_otus/$prefix\_rep_set.fasta -m muscle -o $reg\_otus/muscle_alignment/\n";
  print $sh "ln -s $db_path{$db}/$db_fasta[$ind] ./$reg\_otus/$db_fasta[$ind]\n";
  print $sh "ln -s $db_path{$db}/$db_tax[$ind] ./$reg\_otus/$db_tax[$ind]\n";
  print $sh "assign_taxonomy.py -i $reg\_otus/$prefix\_rep_set.fasta -r $reg\_otus/$db_fasta[$ind] -t $reg\_otus/$db_tax[$ind] -o $reg\_otus/$db\_taxonomy --rdp_max_memory 12000\n";
  print $sh "filter_alignment.py -i $reg\_otus/muscle_alignment/$prefix\_rep_set_aligned.fasta -o $reg\_otus/muscle_alignment_filtered --suppress_lane_mask_filter\n";
  print $sh "mkdir $reg\_otus/fasttree_phylogeny\n";
  print $sh "make_phylogeny.py -i $reg\_otus/muscle_alignment_filtered/$prefix\_rep_set_aligned_pfiltered.fasta -o $reg\_otus/fasttree_phylogeny/$prefix\_rep_set_aligned_pfiltered.tre -l $reg\_otus/fasttree_phylogeny/$prefix\_rep_set_aligned_pfiltered.log\n";
  print $sh "make_otu_table.py -i $reg\_otus/$prefix\_otus.txt -t $reg\_otus/$db\_taxonomy/$prefix\_rep_set_tax_assignments.txt -o $reg\_otus/$prefix\_otu_table.biom\n";
  close($sh);
  print `chmod 744 $sh_file`;
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub loadModules
{
  my $fh = shift @_;
  print $fh "module load qiime/$version\n";
  print $fh "module load ncbi-blast\n";
  print $fh "module load FastTree\n";
}

