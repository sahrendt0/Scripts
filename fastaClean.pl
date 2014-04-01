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
my $replace; # force overwrite
GetOptions ('i|input=s' => \$input,
            'o|org=s'   => \$org,
            'h|help'   => \$help,
            'v|verbose' => \$verb,
            'r|replace' => \$replace);
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
  #print $seq_obj->display_id," => ";
  my @old_id = split(/\|/,$seq_obj->display_id);
  my $tmp = $old_id[1];
  #my $num = (split(/\./,$tmp))[1];
  my $num = $old_id[2];
  #$tmp =~ s/\s+$//;
  #$old_id[1] =~ s/\_1//;
  my $ni = join("_",$tmp,$num);
  my $new_id = join("|",$org,$ni);
  #print $new_id;
  #print "\n";
  $seqs{$new_id} = Bio::Seq->new(-display_id => $new_id,
                                    -seq => $seq_obj->seq);
}

foreach my $id (sort {$a cmp $b} keys %seqs){  $seq_out->write_seq($seqs{$id});}
print `mv $input\.clean $input` if ($replace);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
