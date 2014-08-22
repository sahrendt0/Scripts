#!/usr/bin/perl 
# Script: getseqfromfile.pl
# Description: Provide a sequence ID and a fasta flatfile (database) and the script will return the fasta-formatted sequence
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 8.13.14
#       v1.5 : intelligent choice if multiple sequences in a file
################################
use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

my ($org,$seqID,$acc_file);
my $multi;
my ($help,$verb);
my $dir = "/rhome/sahrendt/bigdata/Genomes/Protein";
my %acc;

GetOptions ('f|fasta=s'  => \$org,
            'd|dir=s'    => \$dir,
            'a|accnos=s' => \$acc_file,
            'i|id=s'     => \$seqID,
            'm|multi'    => \$multi,
            'h|help'     => \$help,
            'v|verbose'  => \$verb     # verbose for file output
);

my $usage = "Usage: getseqfromfile.pl -f fastafile [-d dir] -i id | -a accnos_file\nOutput is STDOUT\nUse -m if multiple sequences in accnos file; omit fastafile\n";
die $usage if $help;
die "No IDs provided.\n$usage" if (!$acc_file && !$seqID && !$multi);

#####-----Main-----#####
my $seqio_obj_in;

if(!$multi)
{
  $seqio_obj_in = Bio::SeqIO->new(-file => "$dir/$org",
                                  -format => "fasta");
}

if($acc_file)
{
  open(ACC,"<$acc_file") or die "Can't open $acc_file\n";
  while(my $line = <ACC>)
  {
    next if ($line =~ /^#/);
    chomp $line;
    my ($file,$etc) = split(/\|/,$line);
    $acc{$file}{$line}++;
  }
  close(ACC);
}
else
{
  my $file = (split(/\|/,$org))[0];
  $acc{$file}{$seqID}++;
}

foreach my $key (sort keys %acc)
{
  if($multi)
  {
    my $fastafile = "$dir/$key\_proteins.aa.fasta";
    $seqio_obj_in = Bio::SeqIO->new(-file => $fastafile,
                                    -format => "fasta");
  }
  while(my $seq = $seqio_obj_in->next_seq)
  {
    if(exists $acc{$key}{$seq->display_id})
    {
      my $seqio_obj_out = Bio::SeqIO->new(-fh => \*STDOUT,
                                          -format => "fasta");
      $seqio_obj_out->write_seq($seq);
    }
  }
}

warn "Done\n";
exit(0);

#####-----Subroutines-----#####
