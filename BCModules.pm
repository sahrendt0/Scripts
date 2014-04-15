package BCModules;
# Name: BCModules.pm
# Description: Biocluster specific sequence analysis modules
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.18.2014
#######################
use strict;
use Bio::Seq;
use Bio::SeqIO;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(indexProteomes 
                 indexTaxonomy
                 indexPFAM
); # export always

our $dbDir = "/rhome/sahrendt/bigdata/Genomes";
our $protDir = "$dbDir/Protein";
our $funcDir = "$dbDir/Functional";
our $PFAMDir = "$funcDir/PFAM";

#######
## Subroutine: indexPFAM
#  Input:
#  Returns: 
###############
sub indexPFAM
{
  my %hash;
  my $pfamFile = shift @_;
  $pfamFile = join("/",$PFAMDir,$pfamFile);
  my @key_names = qw(PROTEIN_NAME LOCUS GENE_CONTIG PFAM_ACC PFAM_NAME PFAM_DESCRIPTION PFAM_START PFAM_STOP LENGTH PFAM_SCORE PFAM_EXPECTED);
  open(my $fh, "<", $pfamFile) or die "Can't open $pfamFile: $!\n";
  my $lc = -1;
  while (my $line = <$fh>)
  {
    $lc++;
    chomp $line;
    next if($line =~ /^#/);
    next if($lc == 0);
    my @data = split(/\t/,$line);
    $hash{$data[1]}{$key_names[0]} = $data[0];
    $hash{$data[1]}{$key_names[2]} = $data[2];
    push( @{$hash{$data[1]}{$key_names[3]}}, $data[3]);
    push( @{$hash{$data[1]}{$key_names[4]}}, $data[4]);
    push( @{$hash{$data[1]}{$key_names[5]}}, $data[5]);
    push( @{$hash{$data[1]}{$key_names[6]}}, $data[6]);
    push( @{$hash{$data[1]}{$key_names[7]}}, $data[7]);
    push( @{$hash{$data[1]}{$key_names[8]}}, $data[8]);
    push( @{$hash{$data[1]}{$key_names[9]}}, $data[9]);
    push( @{$hash{$data[1]}{$key_names[10]}}, $data[10]);
  }
  close($fh);
  return %hash;
}

#######
## Subroutine: indexTaxonomy
#  Input: none
#  Returns: a hash with rudimentary taxonomy
##############
sub indexTaxonomy
{
  my %hash;
  my $taxfile = "$dbDir/taxonlist";
  open(TAX,"<$taxfile") or die "Can't open $taxfile: $!\n";
  while (my $line = <TAX>)
  {
    next if ($line =~ /^#/);
    chomp $line;
    my @data = split(/\t/,$line);
    $hash{$data[0]}{"Class"} = $data[1];
    $hash{$data[0]}{"FullName"} = $data[2];
  }
  close(TAX);
  
  return %hash;
}

#######
## Subroutine: indexProteomes
#  Input: none
#  Returns: a hash with display ID keys storing sequence strings
##############
sub indexProteomes
{
  my %hash;
  opendir(DIR,$protDir);
  my @files = grep { /\.fasta$/ } readdir(DIR);
  closedir(DIR);
  
  foreach my $file (@files)
  {
    my $fasta_in = Bio::SeqIO->new(-file => "$protDir/$file",
                                   -format => "fasta");
    while (my $seq_obj = $fasta_in->next_seq)
    {
      $hash{$seq_obj->display_id} = $seq_obj;
    }
  }
  
  return %hash;
}

1;
