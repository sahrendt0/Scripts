#!/usr/bin/perl 
# Script: getseqfromfile.pl
# Description: Provide a sequence ID and a fasta flatfile (database) and the script will return the fasta-formatted sequence
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.26.13
################################
use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

my ($org,$seqID,$acc_file);
my $help = 0;
my $dir = ".";
my %acc;

GetOptions ('f|fasta=s' => \$org,
            'd|dir=s'   => \$dir,
            'a|accnos=s' => \$acc_file,
            'i|id=s' => \$seqID,
            'h|help+'=> \$help);

my $usage = "Usage: getseqfromfile.pl -f fastafile [-d dir] -i id | -a accnos_file\n";
die $usage if $help;
die "No IDs provided.\n$usage" if (!$acc_file || !$seqID);

my $seqio_obj_in = Bio::SeqIO->new(-file => "$dir/$org\.fasta",
                                   -format => "fasta");

if($acc_file)
{
  open(ACC,"<$acc_file") or die "Can't open $acc_file\n";
  while(my $line = <ACC>)
  {
    next if ($line =~ /^#/);
    chomp $line;
    $acc{$line}++;
  }
  close(ACC);
}
else
{
  $acc{$seqID}++;
}

while(my $seq = $seqio_obj_in->next_seq)
{
  if(exists $acc{$seq->display_id})
  {
    my $seqio_obj_out = Bio::SeqIO->new(-fh => \*STDOUT,
                                        -format => "fasta");
    $seqio_obj_out->write_seq($seq);
  }
}
