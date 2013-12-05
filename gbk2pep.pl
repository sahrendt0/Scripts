#!/usr/bin/perl
# Script gbk2pep.pl
# Description: Parses out translated regions from a genbank file
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.04.2013
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: gbk2pep.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

my $seq_io = Bio::SeqIO->new(-file => "$input",
                             -format => "genbank");

while(my $seq_obj = $seq_io->next_seq)
{
  for my $feat ($gbk->get_SeqFeatures) 
  {
    print "primary tag: ", $feat->primary_tag, "\n";
    for my $tag ($feat->get_all_tags)
    {
      print "  tag: ", $tag, "\n";
      for my $value ($feat->get_tag_values($tag))
      {
        print "    value: ", $value, "\n";
      }
    }
  }
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
