#!/usr/bin/perl
# Script: /rhome/sahrendt/Scripts/qiime_workflow.pl
# Description: Generate shell scripts for processing qiime general workflow 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.10.2014
#       04.23.2014 : Merged w/ qiime_visualize
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Cwd;

#####-----Global Variables-----#####
my $PWD = getcwd;
my $analyze = 1;
my $dataset;
my ($db,@db_fasta,@db_tax);
my %db_path = ("UNITE"   => "/rhome/sahrendt/bigdata/Built_Env/dbs/UNITE",
                "KS"     => "/rhome/sahrendt/bigdata/Built_Env/dbs/Seifert_ITS_refdb",
                "Merged" => "/rhome/sahrendt/bigdata/Built_Env/dbs/Merged");
my @DB_OPTIONS = keys(%db_path);
my (@seq_dir,@otu_dir);
my $RR;
my $version = "1.6.0-dev";

# For visualize step
my $visualize = 0; # set to 1 to visualize
my $mapping;  # dataset specific mapping file
my $a_div_measures = "shannon,PD_whole_tree,chao1,observed_species";
my $b_div_meth = "weighted_unifrac";
my ($help,$verb);
my $singlemode;

GetOptions( 'dataset=s'   => \$dataset,
            'database=s'  => \$db,
            'rr'          => \$RR,  # set to use "random removed" database
            'analyze=i'   => \$analyze,
            'visualize=i' => \$visualize,
            'version=s'   => \$version,
            'h|help'      => \$help,
            'v|verbose'   => \$verb,
            's|single'    => \$singlemode);

my $usage = "Usage: qiime_workflow_general.pl --database database --dataset dataset [--version] [--analyze] [--visualize]
  Default version = $version
  Default analyze = $analyze, visualize = $visualize\n";
die $usage if $help;
die "No dataset.\n$usage" if !$dataset;
die "No database.\n$usage" if !$db;
die "Unknown database: \"$db\".\nOptions: @DB_OPTIONS\n$usage" if (!exists $db_path{$db});

#####-----Main-----#####
if(!$singlemode)
{
  opendir(DIR,$PWD);
  @seq_dir = grep {-l "$PWD/$_"} readdir(DIR);
  closedir(DIR);
}
else
{
  opendir(DIR,$PWD);
  @seq_dir = grep {-d "$PWD/$_"} readdir(DIR);
  closedir(DIR);
}

foreach my $dir (@seq_dir)
{
  push(@otu_dir, join("_",$dir,"otus"));
}

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
$ind = 1 if $RR;

$mapping = join("_",lc($dataset),"mapping.txt");
my $sh; #filehandle
foreach my $reg (@seq_dir)
{
  print $reg,"\n" if $verb;
  my $sh_file; # = "qiime_$dataset\_$db\_$reg\.sh";
  opendir(REG,$reg);
  my @fasta = grep { /\.f.+$/ } readdir(REG);
  closedir(REG);
  my $orig_fasta = shift @fasta;
  my $prefix = (split(/\./,$orig_fasta))[0];
  if(!$singlemode)
  {
    $prefix = $reg if ($dataset eq "Kinney");
    $prefix = join("_",(split(/\_/,$reg))[0],$prefix) if ($dataset eq "Amend");
  }

  if($analyze)
  {
    $sh_file = "qiime_$dataset\_$db\_$reg.sh";
    open($sh, ">", $sh_file);
    loadModules($sh);
    print $sh "pick_otus.py -i $reg/$orig_fasta -o $reg\_otus/\n";
    if(($dataset eq "Amend") or ($dataset eq "Kinney"))
    {
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

  if($visualize)
  {
    $sh_file = "qiime_$dataset\_$db\_$reg\_visualize.sh";
    print "pref: $prefix\n" if $verb;
    $reg = join("_",$reg,"otus");
    opendir(REG,$reg);
    my $biom_file = (grep {/\.biom$/ } readdir(REG))[0];
    close(REG);
    print "$biom_file\n" if $verb;
    open($sh, ">", $sh_file);
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
