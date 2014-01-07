#!/usr/bin/perl
# Script patternAnalysis.pl
# Description: A script to analyze patterns in the flagella (gain/loss) search
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.06.2014
##################################
# Patterns to use:
#  All EDF:           Aloc Amac Bden Cang Ecun Eint Gpro Hpol PirE [OrpC] Rall Spun
#    All flagellated: Amac Bden Cang Gpro Hpol PirE [OrpC] Rall Spun
#    All chytrid:     Bden Gpro Hpol Spun
#    All blasto:      Amac Cang
#    All neo:         PirE [OrpC]
#    All Crypto:      Rall
#    All Micro:       Aloc Ecun Eint
#  non-EDF:           Afum Ccin Ccor Cneo Crev Ncra Rory Scer Umay
#    Zygo:            Ccor Crev Rory
#    Dik:             Afum Ccin Cneo Ncra Scer Umay
#      Asco:          Afum Ncra Scer
#      Basid:         Ccin Cneo Umay
###################################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $infile;
my ($help,$verb,$all);
my $db_dir = "/rhome/sahrendt/bigdata/Chytrid_Rhodopsin/flagellum/flag_cluster/clean";
my %proteome;

my %gene_pattern; # Master hash
my %only_EDF; # hash for genes only found in EDF organisms
my %only_flag; # hash for genes only found in flagellated organisms
my %no_dikarya; # hash for genes NOT found in Dikarya organisms
my %Chy_no_Blasto; # hash for genes in Chytridio but not in Blasto

## Groups to match
my $total = 21;    # total number of proteomes
my $total_flag = 8; # total number of flagellated EDF proteomes
my $thresh = 0.7;
my %EDF = map {$_ => 1} qw(Aloc Amac Bden Cang Ecun Eint Gpro Hpol PirE Rall Spun); # Chytrid, Blasto, Micro, Crypto, Neo
my %EDF_flag = map {$_ => 1} qw(Amac Bden Cang Gpro Hpol PirE Rall Spun); # EDF minus Microsporidia
my %Chytrid = map {$_ => 1} qw(Bden Gpro Hpol Spun); # Chytridiomycota
my %Blasto = map {$_ => 1} qw(Amac Cang); # Blastocladiomycota
my %Neo = map {$_ => 1} qw(PirE); # Neocallimastigomycota
my %Crypto = map {$_ => 1} qw(Rall); # Cryptomycota
my %Micro = map {$_ => 1} qw(Aloc Ecun Eint); # Microsporidia
my %nonEDF = map{$_ => 1} qw(Afum Ccin Ccor Cneo Crev Ncra Rory Scer Umay); # Zygo, Asco, Basidio
my %Zygo = map{$_ => 1} qw(Ccor Crev Rory);
my %Dik = map {$_ => 1} qw(Afum Ccin Cneo Ncra Scer Umay); # Asco, Basidio
my %Asco = map {$_ => 1} qw(Afum Ncra Scer);
my %Basid = map {$_ => 1} qw(Ccin Cneo Umay);
my %Out = map {$_ => 1} qw(Srot);

GetOptions ('i|input=s' => \$infile,
            'h|help'    => \$help,
            'v|verbose' => \$verb,
            'a|all'     => \$all);
my $usage = "Usage: patternAnalysis.pl -a|-i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$infile && !$all);

#####-----Main-----#####
my @infiles;
if($all)
{
  opendir(DIR,".");
  @infiles = grep {/.+gene_patterns\.tab/} readdir(DIR);
  close(DIR);
}
else
{
  push(@infiles,$infile);
}

foreach my $input (sort @infiles)
{
  ## Get the current organism and hash its proteome
  my $current_org = (split(/\./,$input))[0];
  die "Can't find $current_org.fasta in $db_dir\n" if (!(-e "$db_dir/$current_org.fasta"));
  my $seq_io = Bio::SeqIO->new(-file => "$db_dir/$current_org.fasta",
                               -format => "fasta");
  while(my $seq_obj = $seq_io->next_seq)
  {
    $proteome{$seq_obj->display_id} = $seq_obj;
  }

  #print $current_org,"\n";
  open(IN,"<$input") or die "Can't open $input.\n";
  while(my $line = <IN>)
  {
    chomp $line;
    my($gene,$pattern) = split(/\t/,$line);
    next if ($pattern eq "");
  #  print $line,"\n";
    
    my %org = map {$_ => 1} split(/,/,$pattern);
    $org{$current_org} = 1;
    $gene_pattern{$current_org}{$gene}{'Hits'} = \%org; 
    foreach my $hit (sort keys %org)
    {
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Total_hits'}++;
      $gene_pattern{$current_org}{$gene}{'Stats'}{'EDF_hits'}++ if(exists $EDF{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Flag_hits'}++ if(exists $EDF_flag{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Chytrid_hits'}++ if(exists $Chytrid{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Blasto_hits'}++ if(exists $Blasto{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Neo_hits'}++ if(exists $Neo{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Micro_hits'}++ if(exists $Micro{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Crypto_hits'}++ if(exists $Crypto{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'nonEDF_hits'}++ if(exists $nonEDF{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Zygo_hits'}++ if(exists $Zygo{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Dikarya_hits'}++ if(exists $Dik{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Asco_hits'}++ if(exists $Asco{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'Basidio_hits'}++ if(exists $Basid{$hit});
      $gene_pattern{$current_org}{$gene}{'Stats'}{'OG_hits'}++ if(exists $Out{$hit});
    }
  
    ## Copy the EDF-exclusive genes
    if ($gene_pattern{$current_org}{$gene}{'Stats'}{'EDF_hits'})
    {
      if($gene_pattern{$current_org}{$gene}{'Stats'}{'EDF_hits'} == $gene_pattern{$current_org}{$gene}{'Stats'}{'Total_hits'})
      {
        $only_EDF{$current_org}{$gene} = $gene_pattern{$current_org}{$gene};
      }
    }
  
    ## Copy the Flagellated-exclusive genes
    if ($gene_pattern{$current_org}{$gene}{'Stats'}{'Flag_hits'})
    {
      if($gene_pattern{$current_org}{$gene}{'Stats'}{'Flag_hits'} == $gene_pattern{$current_org}{$gene}{'Stats'}{'Total_hits'})
      {
        $only_flag{$current_org}{$gene} = $gene_pattern{$current_org}{$gene};
      }
    }
  
    ## Copy the flagellated but non-dikarya genes
    if($gene_pattern{$current_org}{$gene}{'Stats'}{'Flag_hits'})
    {
      $no_dikarya{$current_org}{$gene} = $gene_pattern{$current_org}{$gene} if(!($gene_pattern{$current_org}{$gene}{'Stats'}{'Dikarya_hits'}) && ($gene_pattern{$current_org}{$gene}{'Stats'}{'Flag_hits'} >= ($total_flag*$thresh)));
    }

    ## Copy the Chytridio but not Blasto
    if($gene_pattern{$current_org}{$gene}{'Stats'}{'Chytrid_hits'})
    {
      $Chy_no_Blasto{$current_org}{$gene} = $gene_pattern{$current_org}{$gene} if(!($gene_pattern{$current_org}{$gene}{'Stats'}{'Blasto_hits'}) && ($gene_pattern{$current_org}{$gene}{'Stats'}{'Chytrid_hits'} >= 3)); # there are only 4 chytridiomycota, so this is an "all-but-one" deal
    }
  }
  close(IN);
  
  
#####-----Output-----#####
  #print Dumper \%gene_pattern;
  #print Dumper \%only_flag;
  #print Dumper \%no_dikarya;
  
  ## Write some fasta files
  # No-dikarya
  writeOut($current_org,\%no_dikarya,"no_dikarya");

  # Chytrid but not Blasto
  writeOut($current_org,\%Chy_no_Blasto,"CNB");
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub writeOut
{
  my $org = shift @_;
  my %patterns = %{shift @_};
  my $fName = shift @_;
  my $seq_out = Bio::SeqIO->new(-file => ">$org.$fName.fasta",
                                -format => "fasta");

  foreach my $key (sort keys %{$patterns{$org}})
  {
    $seq_out->write_seq($proteome{$key});
  }
}
