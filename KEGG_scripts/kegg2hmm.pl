#!/usr/bin/perl
# Script: kegg2hmm.pl
# Description: Given a KEGG gene id, gets homologs from KEGG and creates an HMM for further searches 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.13.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $scripts_dir = "/rhome/sahrendt/Scripts";
my @HMMGroups = qw(Eukaryota Viridiplantae); # groups to use for HMM generation

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: kegg2hmm.pl -i input\nGiven a KEGG gene id, gets homologs from KEGG and creates an HMM for further searches\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
downloadGenes($input);
system("$scripts_dir/KEGG_scripts/parseKEGGgenes.pl");

#foreach my $grp (@HMMGroups)
#{
#  system("cat $grp/*.faa > total_$grp.faa");
#}
#system("cat *.faa > total_Groups.faa");
#system("$scripts_dir/fasta2hmm.pl -i total_Groups.faa -s");
#system("./fas2hmm.sh");
#system("$scripts_dir/hmm_run.pl -p hmmsearch -i ./total_Groups.hmm -d ~/bigdata/Genomes/Protein/ -t $input");

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub downloadGenes {
  my $KEGG_id = shift @_;
  my $kegg_dir = "$scripts_dir/KEGG_scripts";
  system("$kegg_dir/kegg.pl -o get -a $KEGG_id");
  system("$kegg_dir/process_kegg.pl -i $KEGG_id");
  system("$kegg_dir/getkegg.pl -i $KEGG_id\_genelist");
}
