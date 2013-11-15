package SeqAnalysis;
# Name: SeqAnalysis.pm
# Description: Perl module containing often-used subroutines for sequence processing
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.13.13
#######################
# Functionality includes:
#  [x] gc content		: getGC(str dna)
#  [x] protein mass		: getProtMass(str prot)
#  [ ] N50 
#  [x] hamming distance		: getHammDist(str dna1, str dna2)
#  [x] reverse complement	: getRevComp(str dna)
#  [x] transcribe to RNA	: transcribe(str dna)
#  [x] motif finding		: getMotifPos(str seq, str match)
#  [x] 6 frame translation	: getSixFrame(str dna)
#  [ ] reverse translation	: revTrans(str prot)
#  [x] get profile from align	: getProfile(hash_ref alignment)
#  [x] get consensus from prof	: getConsensus(hash_ref profile)
#  [x] remove an intron		: removeIntron(str dna, str intron)
#  [x] transition/transversion  : getTTRatio(str dna1, str dna2)
########################
use strict;
use warnings;
use Bio::Perl;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(getTTRatio removeIntron getConsensus getProfile revTrans getSixFrame seqTranslate getMotifPos getGC getProtMass getHammDist getRevComp transcribe); # export always

our %CODONS_3 = ("MET" => ["ATG"],
                 "ILE" => ["ATA","ATC","ATT"],
                 "ARG" => ["CGG","CGT","CGA","CGC","AGG","AGA"],
                 "GLN" => ["CAG","CAA"],
                 "HIS" => ["CAC","CAT"],
                 "PRO" => ["CCA","CCG","CCC","CCT"],
                 "LEU" => ["CTT","CTA","CTC","CTG","TTA","TTG"],
                 "TRP" => ["TGG"],
                 "CYS" => ["TGC","TGT"],
                 "TYR" => ["TAT","TAC"],
                 "PHE" => ["TTT","TTC"],
                 "GLY" => ["GGG","GGT","GGC","GGA"],
                 "GLU" => ["GAA","GAG"],
                 "ASP" => ["GAT","GAC"],
                 "ALA" => ["GCC","GCA","GCT","GCG"],
                 "VAL" => ["GTA","GTC","GTG","GTT"],
                 "SER" => ["TCA","TCT","TCG","TCC","ATC","AGT"],
                 "LYS" => ["AAA","AAG"],
                 "ASN" => ["AAT","AAC"],
                 "THR" => ["ACA","ACT","ACC","ACG"],
                 "***" => ["TGA","TAA","TAG"]);

our %CODONS_1 = ("M" => ["ATG"],
                 "I" => ["ATA","ATC","ATT"],
                 "R" => ["CGG","CGT","CGA","CGC","AGG","AGA"],
                 "Q" => ["CAG","CAA"],
                 "H" => ["CAC","CAT"],
                 "P" => ["CCA","CCG","CCC","CCT"],
                 "L" => ["CTT","CTA","CTC","CTG","TTA","TTG"],
                 "W" => ["TGG"],
                 "C" => ["TGC","TGT"],
                 "Y" => ["TAT","TAC"],
                 "F" => ["TTT","TTC"],
                 "G" => ["GGG","GGT","GGC","GGA"],
                 "E" => ["GAA","GAG"],
                 "D" => ["GAT","GAC"],
                 "A" => ["GCC","GCA","GCT","GCG"],
                 "V" => ["GTA","GTC","GTG","GTT"],
                 "S" => ["TCA","TCT","TCG","TCC","ATC","AGT"],
                 "K" => ["AAA","AAG"],
                 "N" => ["AAT","AAC"],
                 "T" => ["ACA","ACT","ACC","ACG"],
                 "*" => ["TGA","TAA","TAG"]);

our %prot_mass = ('A' => 71.03711,
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

our %AA = ("ATG" => "M",
           "ATA" => "I",
           "ATC" => "I",
           "ATT" => "I",
           "CGG" => "R",
           "CGT" => "R",
           "CGA" => "R",
           "CGC" => "R",
           "AGG" => "R",
           "AGA" => "R",
           "CAG" => "Q",
           "CAA" => "Q",
           "CAC" => "H",
           "CAT" => "H",
           "CCA" => "P",
           "CCG" => "P",
           "CCC" => "P",
           "CCT" => "P",
           "CTT" => "L",
           "CTA" => "L",
           "CTC" => "L",
           "CTG" => "L",
           "TTA" => "L",
           "TTG" => "L",
           "TGG" => "W",
           "TGC" => "C",
           "TGT" => "C",
           "TAT" => "Y",
           "TAC" => "Y",
           "TTT" => "F",
           "TTC" => "F",
           "GGG" => "G",
           "GGT" => "G",
           "GGC" => "G",
           "GGA" => "G",
           "GAA" => "E",
           "GAG" => "E",
           "GAT" => "D",
           "GAC" => "D",
           "GCC" => "A",
           "GCA" => "A",
           "GCT" => "A",
           "GCG" => "A",
           "GTA" => "V",
           "GTC" => "V",
           "GTG" => "V",
           "GTT" => "V",
           "TCA" => "S",
           "TCT" => "S",
           "TCG" => "S",
           "TCC" => "S",
           "ATC" => "S",
           "AGT" => "S",
           "AAA" => "K",
           "AAG" => "K",
           "AAT" => "N",
           "AAC" => "N",
           "ACA" => "T",
           "ACT" => "T",
           "ACC" => "T",
           "ACG" => "T",
           "TGA" => "*",
           "TAA" => "*",
           "TAG" => "*");

sub changeType
{
  my $base1 = uc(shift @_);
  my $base2 = uc(shift @_);
  my $change = "none";

  if($base1 eq "A")
  {
    if($base2 eq "G")
    {
      $change = "transition";
    }
    elsif(($base2 eq "C") or ($base2 eq "T"))
    {
      $change = "transversion";
    }
  }
  elsif($base1 eq "G")
  {
    if($base2 eq "A")
    { 
      $change = "transition";
    }
    elsif(($base2 eq "C") or ($base2 eq "T"))
    { 
      $change = "transversion";
    }
  }
  elsif($base1 eq "C")
  {
    if($base2 eq "T")
    {    
      $change = "transition";
    }
    elsif(($base2 eq "G") or ($base2 eq "A"))
    {     
      $change = "transversion";
    }
  }
  else # T
  {
    if($base2 eq "C")
    {    
      $change = "transition";
    }
    elsif(($base2 eq "G") or ($base2 eq "A"))
    {    
      $change = "transversion";
    }
  }
  return $change;
}

#####
## Subroutine: getTTRatio
#    Input: two dna strings
#    Returns: ratio
########
sub getTTRatio
{
  my @seq1 = split(//,shift @_);
  my @seq2 = split(//,shift @_);
  my %changes = ("transition"  => 0,
                 "transversion" => 0,
                 "none"         => 0);

  my $TTRatio = 0;

  for(my $i=0;$i<scalar(@seq1);$i++)
  {
    $changes{changeType($seq1[$i],$seq2[$i])}++;
  }
  $TTRatio = $changes{"transition"} / $changes{"transversion"};
  return $TTRatio;
}

#####
## Subroutine: removeIntron
#    Input: dna string and intron
#    Returns: DNA string without intron
########
sub removeIntron
{
  my $seq = shift @_;
  my $intron = shift @_;
  my $result = $seq;
  if($seq =~ /(.*)$intron(.*)/)
  {
    $result = $1.$2;
  }
  return $result;
}


#####
## Subroutine: getConsensus
#    Input:
#    Returns: 
########
sub getConsensus
{
  my %profile = %{shift @_};
  my $cons = "";
  my $al_len = scalar @{$profile{'A'}};
  for(my $i=0;$i<$al_len;$i++)
  {
    my $max = 0;
    my $c = "";
    foreach my $key (keys %profile)
    {
      my $value = $profile{$key}[$i];
      if($value > $max)
      {
        $max = $value;
        $c = $key;
      }
    }
   $cons .= $c;
  }

  return $cons;
}

#####
## Subroutine: getProfile
#    Input: hash of aligned sequences
#    Returns: hash of profile
########
sub getProfile
{
  my $align = shift @_; # hash reference
  my @accnos = sort(keys(%{$align}));  
  my $al_len = length($align->{$accnos[0]});
  
  my @init;
  my %profile = ('A' => [],
                 'T' => [],
                 'G' => [],
                 'C' => []);

  for(my $i=0;$i<$al_len;$i++)
  {
    foreach my $key (keys %profile)
    {
      $profile{$key}[$i] = 0;
    }
  }
 
  for(my $i=0;$i<$al_len;$i++)
  {
    foreach my $acc (@accnos)
    {
      my @seq = split(//,$align->{$acc});
      $profile{$seq[$i]}[$i]++;
    }
  }

  return %profile;
}

#####
## Subroutine: seqTranslate
#    Input: DNA string
#    Returns: use BioPerl to translate sequence
########
sub seqTranslate
{
  my $seq = shift @_;
  my $seq_obj = Bio::Seq->new(-seq => $seq);
  return $seq_obj->translate->seq;
}

#####
## Subroutine: revTrans
#    Input: protein string (one-letter)
#    Returns: total num of possible RNA strings for protein (mod 1,000,000)
########
sub revTrans
{
  my $prot = shift @_;
  my $num_RNA = 1;
  if($prot !~ /\*$/)
  {
    $prot .= "*";
  }
  foreach my $aa (split(//,$prot))
  {
    $num_RNA *= scalar(@{$CODONS_1{$aa}});
  }
  return ($num_RNA%1000000);
}

#####
## Subroutine: getSixFrame
#    Input: string of DNA
#    Returns: array of unique potential orfs
########
sub getSixFrame
{
  my $seq = shift @_;
  my $rc = getRevComp($seq);
  my @frame1 = $seq =~ /(.{3})/g;
  my @frame2 = substr($seq,1) =~ /(.{3})/g;
  my @frame3 = substr($seq,2) =~ /(.{3})/g;
  my @frame4 = $rc =~ /(.{3})/g;
  my @frame5 = substr($rc,1) =~ /(.{3})/g;
  my @frame6 = substr($rc,2) =~ /(.{3})/g;
  my %orfs;
  my @frames = (\@frame1,\@frame2,\@frame3,\@frame4,\@frame5,\@frame6);
  foreach my $frame (@frames)
  {
    my $len = scalar(@{$frame}); 
    for(my $i=0;$i<$len;$i++)
    {
      my $codon = @{$frame}[$i];
      if($codon eq "ATG")
      {
        my @tmp = ($codon);
        #print "$codon($i)<$len>:";
        my @sub = @{$frame}[($i+1)..($len-1)];
        #print "@sub";
        my $j=0;
        while($j < scalar(@sub))#   $j<scalar(@sub))
        {
          #print "$sub[$j]:";
          if($sub[$j] =~ /TAA|TAG|TGA/)
          {
            $orfs{seqTranslate(join("",@tmp))}++;
            last;
          }
          push (@tmp,$sub[$j]);
          $j++;
        }
        #print "\n";
      }
    }
  }
  return %orfs;
}

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
  my $mass = 0;
  foreach my $res (split(//,uc($seq)))
  {
    $mass += $prot_mass{$res};
  }
  return $mass;
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
