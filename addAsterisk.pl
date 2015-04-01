#!/usr/bin/perl
# Script: addAsterisk.pl
# Description: Appends sequences with an asterisk 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.11.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: addAsterisk.pl -i input\nAppends sequences with an asterisk\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $seqin_obj = Bio::SeqIO->new(-file => "$input",
                                -format => "Fasta");

while(my $seq_obj = $seqin_obj->next_seq)
{
  my $new_seq = $seq_obj->seq;
  $new_seq = join("",$new_seq,"*") if($new_seq !~ /\*$/);

  $seq_obj->seq
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
