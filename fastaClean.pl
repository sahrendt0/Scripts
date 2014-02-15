#!/usr/bin/perl
# Script: fastaClean.pl
# Description: Cleans up fasta descriptions (Not for general use; highly specific) 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.16.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $input;
my $org;
my %seqs;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'o|org=s'   => \$org,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: fastaClean.pl -i input -o orgAbbr\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);
die "No organism.\n$usage" if (!$org);

#####-----Main-----#####
my $seq_in = Bio::SeqIO->new(-file => $input,
                             -format => "fasta");
my $seq_out = Bio::SeqIO->new(-file => ">$input\.clean",
                              -format => "fasta");
while(my $seq_obj = $seq_in->next_seq)
{
#  print $seq_obj->display_id,"\n";
  my @old_id = split(/\|/,$seq_obj->display_id);
  my $tmp = join("_",$org,$old_id[1]);
  my $new_id = join("|",$old_id[0],$tmp);
  $seqs{$old_id[1]} = Bio::Seq->new(-display_id => $new_id,
                                 -seq => $seq_obj->seq);
}

foreach my $id (sort {$a <=>$b} keys %seqs)
{
  $seq_out->write_seq($seqs{$id});
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
