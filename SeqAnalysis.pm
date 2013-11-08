package SeqAnalysis;
# Name: SeqAnalysis.pm
# Description: Perl module containing often-used subroutines for sequence processing
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.5.13
#######################
# Functionality includes:
#  [x] gc content		: getGC(str dna)
#  [x] protein mass		: getProtMass(str prot)
#  [ ] N50 
#  [x] hamming distance		: getHammDist(str dna1, str dna2)
#  [x] reverse complement	: getRevComp(str dna)
#  [x] transcribe to RNA	: transcribe(str dna)
#  [x] motif finding		: getMotifPos(str seq, str match)
########################
use strict;
use warnings;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(getMotifPos getGC getProtMass getHammDist getRevComp transcribe); # export always

#####
## Subroutine: getMotifPos
#    Input: sequence,pattern
#    Returns: Array of positions of each match (0 index)
#    Works using "sliding window" of length of match
########
sub getMotifPos
{
  my $seq = shift @_;
  my $match = shift @_;
  my @matches;
  for(my $i=0;$i<length($seq);$i++)
  {
    if(substr($seq,$i,length($match)) eq $match)
    {
      push(@matches,$i);
    }
  }
  return @matches;
}


#####
## Subroutine: getRevComp
#    Input: a DNA string
#    Returns: the reverse complement
########
sub getRevComp
{
  my $seq = shift @_;
  my $rc = reverse $seq;
  $rc =~ tr/ATGCatgc/TACGtacg/;
  return $rc;
}

#####
## Subroutine: transcribe
#    Input: a DNA string
#    Returns: the RNA string
########
sub transcribe
{
  my $seq = shift @_;
  $seq =~ tr/Tt/Uu/;
  return $seq;
}

#####
## Subroutine: getProtMass
#    Input: a protein string
#    Returns: the mass of the protein in kDa
#    Calls: initProtMass
#########
sub getProtMass
{
  my $seq = shift @_;
  my %mass_table = initProtMass();
  my $mass = 0;
  foreach my $res (split(//,uc($seq)))
  {
    $mass += $mass_table{$res};
  }
  return $mass;
}

#####
## Subroutine: initProtMass
#    Returns: a hash with amino acid to kDa mass mapping
#########
sub initProtMass
{
  return my %prot_mass = ( 'A' => 71.03711,
                           'C' => 103.00919,
                           'D' => 115.02694,
                           'E' => 129.04259,
                           'F' => 147.06841,
                           'G' => 57.02146,
                           'H' => 137.05891,
                           'I' => 113.08406,
                           'K' => 128.09496,
                           'L' => 113.08406,
                           'M' => 131.04049,
                           'N' => 114.04293,
                           'P' => 97.05276,
                           'Q' => 128.05858,
                           'R' => 156.10111,
                           'S' => 87.03203,
                           'T' => 101.04768,
                           'V' => 99.06841,
                           'W' => 186.07931,
                           'Y' => 163.06333);
}

#####
# Subroutine: getHammDist
#    Input: two strings
#    Returns: the hamming distance between the two
#########
sub getHammDist
{
  my $str1 = shift @_;
  my @str1 = split(//,$str1);
  my $str2 = shift @_;
  my @str2 = split(//,$str2);
  my $hamm = 0;  # the Hamming Distance b/w str1 and str2
  for(my $i=0;$i<scalar(@str1); $i++)
  {
    #print "$str1[$i] :: $str2[$i]\n";
    if($str1[$i] ne $str2[$i])
    {
      $hamm++;
    }
  }
  return $hamm;
}


#####
## Subroutine: isDNA 
#    Input: a string
#    Returns: 1 if string is DNA, 0 otherwise
#########
sub isDNA
{
  my $seq = shift @_;
  my $isDNA = 0;
  
  return $isDNA;
}

#####
## Subroutine: getGC
#    Input: a DNA sequence
#    Returns: decimal representation of GC-content
#########
sub getGC
{
  my $seq = shift @_;
  my $gc = 0;
  foreach my $base (split(//,uc($seq)))
  {
    if(($base eq "G") or ($base eq "C"))
    {
      $gc++;
    }
  } 
  return $gc/length($seq);
}

1;
