package SeqAnalysis;
# Name: SeqAnalysis.pm
# Description: Perl module containing often-used subroutines for sequence processing
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.11.13
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
#  [x] get sequences		: getSeqs(str fasta_filename, arrayref accnos)
########################
use strict;
use warnings;
use Bio::Perl;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(getSeqs revTrans getSixFrame seqTranslate getMotifPos getGC getProtMass getHammDist getRevComp transcribe); # export always

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

#our %AA = ("ATG" => "M",
#           "ATA" => "I",
#           "ATC" => "I",
#           "ATT" => "I",
#           "CGG" => "R",
#           "CGT" => "R",
#           "CGA" => "R",
#           "CGC" => "R",
#           "AGG" => "R",
#           "AGA" => "R",
# 49                  "Q" => {"CAG","CAA"},
# 50                  "H" => {"CAC","CAT"},
# 51                  "P" => {"CCA","CCG","CCC","CCT"},
# 52                  "L" => {"CTT","CTA","CTC","CTG","TTA","TTG"},
# 53                  "W" => {"TGG"},
# 54                  "C" => {"TGC","TGT"},
# 55                  "Y" => {"TAT","TAC"},
# 56                  "F" => {"TTT","TTC"},
# 57                  "G" => {"GGG","GGT","GGC","GGA"},
# 58                  "E" => {"GAA","GAG"},
# 59                  "D" => {"GAT","GAC"},
# 60                  "A" => {"GCC","GCA","GCT","GCG"},
# 61                  "V" => {"GTA","GTC","GTG","GTT"},
# 62                  "S" => {"TCA","TCT","TCG","TCC","ATC","AGT"},
# 63                  "K" => {"AAA","AAG"},
# 64                  "N" => {"AAT","AAC"},
# 65                  "T" => {"ACA","ACT","ACC","ACG"},
# 66                  "***" => {"TGA","TAA","TAG"});
#);

#####
## Subroutine:
#    Input: Sequence hash, accnos array
#    Returns: none; write out to file
#######
sub getSeqs
{
  my $fasta_name = shift @_;
  my $accnos = shift @_;
  my $seq_in = Bio::SeqIO->new(-file => "<$fasta_name",
                               -format => "fasta");
  my $seq_out = Bio::SeqIO->new(-file => ">out",
                                -format => "fasta");
  my %fasta;
  while(my $seq = $seq_in->next_seq)
  {
    $fasta{$seq->display_id} = $seq;
  }

  foreach my $acc (@{$accnos})
  {
    if(exists $fasta{$acc})
    {
      $seq_out->write_seq($fasta{$acc});
    }
  }
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
