#!/usr/bin/perl
# Script: dinucl.pl
# Description: Calculates dinucleotide distribution for a given DNA string 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 08.22.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use Data::Dumper;
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: dinucl.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $species = (split(/\_/,$input))[0];
my $seqio_obj = Bio::SeqIO->new(-file => "$input",
                                -format => "fasta");
my %master_hash;
while (my $seq_obj = $seqio_obj->next_seq)
{
  my %tmp_hash = diNucDist($seq_obj->seq);
  foreach my $key (sort keys %tmp_hash)
  {
    $master_hash{$key} += $tmp_hash{$key};
  }
}
open (my $fh,">","$species\_diNuc.tsv");
foreach my $key (sort keys %master_hash)
{
  print $fh "$key\t$master_hash{$key}\n";
}
close($fh);

open(my $rh, ">", "$species\_diNuc.R");
print $rh "#!/usr/bin/R\n";
print $rh "test <- read.table(\"$species\_diNuc.tsv\")\n";
print $rh "pdf(\"$species\_diNucDist.pdf\")\n";
print $rh "barplot(test\$V2,names.arg=test\$V1, cex.names=0.5)\n";
print $rh "dev.off()\n";
close($rh);
system("chmod 744 $species\_diNuc.R");
system("Rscript $species\_diNuc.R");
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
