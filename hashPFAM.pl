#!/usr/bin/perl
# Script: hashPFAM.pl
# Description: Analyse flagellar patterns 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.24.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %pfam_hash;
my $pfam_dir = "/rhome/sahrendt/bigdata/Genomes/Functional/PFAM";
my $pfam_file_ext = "pfam_to_genes.txt";
my $pfam_file;
my $mod; # flag to change transcript name to gene name

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'm|mod'    => \$mod,
            'v|verbose' => \$verb);
my $usage = "Usage: hashPFAM.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $species = (split(/\./,$input))[0];
$pfam_file = "$pfam_dir/$species\_$pfam_file_ext";
%pfam_hash = hashPFAM($pfam_file);
my @pf_keys = keys %pfam_hash;

#print "@pf_keys\n";

open(my $fh, "<", $input);
while(my $line = <$fh>)
{
  chomp $line;
  next if($line =~ /^#/);
  $line =~ s/T\d$//;
#  $line = (split(/\|/,$line))[1];
#  if($mod){$line =~ s/T/G/;}
  if($mod)
  {
    $line =~ s/\|/\_/;
    $line = uc($line);
  }
#  print $line,"\n";
  print $line;
  if(exists $pfam_hash{$line})
  {
    foreach my $key (sort {$pfam_hash{$line}{$a}{"Score"} <=> $pfam_hash{$line}{$b}{"Score"} } keys %{$pfam_hash{$line}})
    {
      print "\t",$key,";",$pfam_hash{$line}{$key}{"Desc"};
    }
  }
  print "\n";
}
close($fh);

#print Dumper \%pfam_hash;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub hashPFAM
{
  my %hash;
  my $infile = shift @_;
  open(my $fh, "<", $infile) or die "Can't open $infile: $!\n";
  while(my $line = <$fh>)
  {
    chomp $line;
    next if($line =~ /^#/);
    my ($PROTEIN_NAME, $LOCUS, $GENE_CONTIG, $PFAM_ACC, $PFAM_NAME, $PFAM_DESCRIPTION, $PFAM_START, $PFAM_STOP, $LENGTH, $PFAM_SCORE, $PFAM_EXPECTED) = split(/\t/,$line);
    $PFAM_ACC =~ s/\.\d+$//;
    $hash{$LOCUS}{$PFAM_ACC}{"Desc"} = $PFAM_DESCRIPTION; 
    $hash{$LOCUS}{$PFAM_ACC}{"Score"} = $PFAM_SCORE; 
    $hash{$LOCUS}{$PFAM_ACC}{"Eval"} = $PFAM_EXPECTED; 
  }
  close($fh);
  return %hash;
}
