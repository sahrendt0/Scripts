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

our @EXPORT = qw(indexProteomes indexTaxonomy); # export always

my $dbDir = "/rhome/sahrendt/bigdata/Genomes";
my $protDir = "$dbDir/Protein";

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
    my $fasta_in = Bio::SeqIO->new(-file => $file,
                                   -format => "fasta");
    while (my $seq_obj = $fasta_in->next_seq)
    {
      $hash{$seq_obj->display_id} = $seq_obj->seq;
    }
  }
  
  return %hash;
}

1;
