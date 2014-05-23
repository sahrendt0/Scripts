#!/usr/bin/perl
# Script: qiime_visualize.pl
# Description: Runs through Alpha and Beta diversity measures 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.17.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Cwd;

#####-----Global Variables-----#####
my $PWD = getcwd;
my $dataset;
my ($db,@db_fasta,@db_tax);
my %db_path = ("UNITE" => "/rhome/sahrendt/bigdata/Built_Env/dbs/UNITE",
               "KS"    => "/rhome/sahrendt/bigdata/Built_Env/dbs/Seifert_ITS_refdb");
my @DB_OPTIONS = keys(%db_path);
my @regs;
my $RR;
my $version = "1.6.0-dev";
my $mapping;# = "amend_mapping.txt";
my $a_div_measures = "shannon,PD_whole_tree,chao1,observed_species";
my $b_div_meth = "weighted_unifrac";
my ($help,$verb);

GetOptions ('dataset=s'  => \$dataset,
            'database=s' => \$db,
            'rr'         => \$RR,
            'version'    => \$version,
            'h|help'     => \$help,
            'v|verbose'  => \$verb);

my $usage = "Usage: qiime_visualize.pl --dataset dataset --database database [--version v]\n";
die $usage if $help;
die "No dataset.\n$usage" if (!$dataset);
die "No database.\n$usage" if (!$db);
die "Unknown database: \"$db\".\nOptions: @DB_OPTIONS\n$usage" if (!exists $db_path{$db});

#####-----Main-----#####
opendir(DIR,$PWD);
@regs = grep {-d "$PWD/$_" } readdir(DIR);
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

my $ind = 0;
$ind = 1 if $RR;

$mapping = join("_",lc($dataset),"mapping.txt");

foreach my $reg (@regs)
{
  next if($reg !~ /otus/);
  print $reg,"\n" if $verb;
  my $prefix;
  $prefix = $reg if ($dataset eq "Kinney");
  $prefix = join("_",(split(/\_/,$reg))[0],"seqs") if ($dataset eq "Amend");
  my $sh_file = "qiime_$dataset\_$db\_$prefix\_visualize.sh";
  opendir(REG,$reg);
  my $biom_file = (grep { /\.biom$/ } readdir(REG))[0];
  print "$biom_file\n" if $verb;
  closedir(REG);
  open(my $sh, ">", $sh_file);
  loadModules($sh);
  print $sh "biom summarize-table -i $reg/$biom_file -o $reg/$prefix\_otu_table_summary.txt\n";
  print $sh "make_otu_heatmap_html.py -i $reg/$biom_file -o $reg/OTU_Heatmap/\n";
  print $sh "make_otu_network.py -m $mapping -i $reg/$biom_file -o $reg/OTU_Network\n";
#  print $sh "summarize_taxa_through_plots.py -i $reg/$biom_file -o $reg/wf_taxa_summary -m $mapping\n";
  print $sh "summarize_taxa.py -i $reg/$biom_file -o $reg/wf_taxa_summary\n";
  print $sh "ls -m $reg/wf_taxa_summary/* \| tr -d '\\n' > $prefix\_list\n";
  print $sh "plot_taxa_summary.py -i \$(<$prefix\_list) -o $reg/plots/\n";
  print $sh "multiple_rarefactions.py -i $reg/$biom_file -m 10 -x 140 -s 10 -n 2 -o $reg/wf_arare/rarefied_otu_tables\n";
  print $sh "alpha_diversity.py -i $reg/wf_arare/rarefied_otu_tables/ -m $a_div_measures -t $reg/fasttree_phylogeny/$prefix\_rep_set_aligned_pfiltered.tre -o $reg/wf_arare/alpha_div/\n";
  print $sh "collate_alpha.py -i $reg/wf_arare/alpha_div/ -o $reg/wf_arare/collated_alpha/\n";
  print $sh "make_rarefaction_plots.py -i $reg/wf_arare/collated_alpha/ -m $mapping -o $reg/wf_arare/plots/\n";
  print $sh "single_rarefaction.py -i $reg/$biom_file -o $reg/$prefix\_otu_table_even100.biom -d 100\n";
  print $sh "beta_diversity.py -i $reg/wf_arare/rarefied_otu_tables/ -m $b_div_meth -t $reg/fasttree_phylogeny/$prefix\_rep_set_aligned_pfiltered.tre -o $reg/wf_bdiv/beta_div\n";
  print $sh "principal_coordinates.py -i $reg/wf_bdiv/beta_div/ -o $reg/wf_bdiv/beta_div_weighted_pcoa_results/\n";
  print $sh "#jackknifed_beta_diversity.py -i $reg/$biom_file -t $reg/fasttree_phylogeny/$prefix\_rep_set_aligned_pfiltered.tre -m $mapping -o $reg/wf_jack -e 110\n";
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
}
