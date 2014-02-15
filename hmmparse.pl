#!/usr/bin/perl 
# Script: hmmparse.pl
# Description: Parses an HMM result file, scan or search
# Author: Steven Ahrendt
# email: sahrend0@gmail.com
# Date: 4.12.13
#         - gather sequences by default
#####################################
# Usage: perl hmmparse.pl [-v] -a [-i input]
#####################################
# If -a argument is used, no need for filename
#####################################

use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;
use Getopt::Long qw(:config bundling);

my (%hits,@files,%all_types);
my $pep_dir = "/rhome/sahrendt/bigdata/Genomes/Protein/";
my $results_dir = ".";
my %peps;

## Command line options
my $verbose = 0;
my $all;
my $sequences = "";
my $input = "";
my $help;
GetOptions ('v|verbose+'  => \$verbose, 
            'a|all'       => \$all,
            's|sequences' => \$sequences,
            'i|input=s'   => \$input,
            'h|help'     => \$help);
my $usage = "Usage: perl hmmparse.pl [-v] -a [-i input]\nIf -a argument is used, no need for filename\nOutput to file: \"out_table\"\n";
die $usage if ($help);
die $usage if (!$input and !$all);


## Index proteomes for searching
opendir(PEP,"$pep_dir");
my @proteomes = grep{ /\.fasta$/ } readdir(PEP);
closedir(PEP);
if ($verbose){print join("\n",@proteomes),"\n";}

foreach my $prot (@proteomes)
{
  my $spec = (split(/[\.\_]/,$prot))[0];
  if($verbose){print $spec,"\n";}
  my $seqio_obj = Bio::SeqIO->new(-file => "$pep_dir/$prot",
                                  -format => 'fasta');
  while(my $seq = $seqio_obj->next_seq)
  {
    $peps{$spec}{$seq->display_id} = $seq;
  }
}


## Process results
if($all)
{
  opendir(DIR, $results_dir);
  @files = grep { /\_tbl\.hmms.+/} readdir(DIR); # get --tblout version of output
  closedir DIR;
}
else
{
  push(@files,$input);
}
#print scalar(@files),"\n";
#print $files[0],"\n";
if (scalar @files > 0)
{
  foreach my $hmmfile (@files)
  {
    my (@seqs,%genes,$gene,$PFAM);
    my ($type,$tmp,$org,$mod,$ext);
    my @flags; # flags for positions of gene, PFAM, type, org
    my @filename = split(/[\-|\.|\_]/,$hmmfile);
    $tmp = $filename[1]; # "vs"
    $mod = $filename[3]; # "tbl"
    $ext = $filename[4];
    if($ext =~ m/scan/)
    {
      @flags = (1,0,2,0);
    }
    if($ext =~ m/search/)
    {
      @flags = (0,1,0,2);
    }
    $type = $filename[$flags[2]];
    $all_types{$type}++;
    $org = $filename[$flags[3]];
    open(HMM, "<$results_dir/$hmmfile") || die "Can't open file \"$hmmfile\".\n";
    my $c = 0; # counter for hits
    foreach my $line (<HMM>)
    {
      chomp $line;
      next if($line =~ m/^#/);
      my ($t_name,$t_acc,$q_name,$q_acc,$full_eval,$full_score,$full_bias,$best_eval,$best_score,$best_bias,$dom_exp,$dom_reg,$dom_clu,$dom_ov,$dom_env,$dom_dom,$dom_rep,$dom_inc,@desc) = split(/\s+/,$line);
      my @newline;
      push(@newline, $t_name); # $newline[0] = $t_name
      push(@newline, $q_name); # $newline[1] = $q_name
      $c++;
      $gene = $newline[$flags[0]];
      $PFAM = $newline[$flags[1]];
      #print "$gene => $PFAM\n";
      $genes{$gene} = $PFAM;
      #print "$gene => ",$genes{$gene},"\n";
    }
    $hits{$org}{$type} = \%genes;
    #print keys %{$hits{$type}{$org}},"\n";
  }
}


## Output
open(OUT,">out_table");
if($verbose){print "Org ";}
print OUT "Org ";
foreach my $t (keys %all_types)
{
  if($verbose){print "$t ";}
  print OUT "$t ";
}
if($verbose){print "\n";}
print OUT "\n";
foreach my $o (sort keys %hits)
{
  if($verbose){print "$o ";}
  print OUT "$o ";
  foreach my $t (keys %{$hits{$o}})
  {
    if($verbose){print scalar (keys %{$hits{$o}{$t}})," ";}
    print OUT scalar (keys %{$hits{$o}{$t}})," ";
    if(scalar (keys %{$hits{$o}{$t}}))
    {
      my $outfasta = Bio::SeqIO->new(-file => ">$o\_$t.faa",
                                     -format => 'fasta');
      foreach my $g (keys %{$hits{$o}{$t}})
      {
        if(exists $peps{$o}{$g}){$outfasta->write_seq($peps{$o}{$g});}
        if($verbose>1){print "$g=>$hits{$o}{$t}{$g} ";}
      }
    }
  }
  if($verbose){print "\n";}
  print OUT "\n";
}
close(OUT);

warn "Done.\n";
exit(0);
