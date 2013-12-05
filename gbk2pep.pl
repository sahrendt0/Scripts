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
my @tmp = split(/\./,$input);
pop @tmp;
my $output = join(".",@tmp);

my $seq_io = Bio::SeqIO->new(-file => "$input",
                             -format => "genbank");
my $prot_out = Bio::SeqIO->new(-file => ">>$output\_proteins.aa.fasta",
                               -format => "fasta");
while(my $seq_obj = $seq_io->next_seq)
{
  my $locus = $seq_obj->display_id;
  if($locus !~ /^Orpinomyces\_(\d+)\.\1$/)
  {
    print $locus,": ";
    print "\n";
  }
  my $seq_obj_out = Bio::Seq->new(-alphabet => "protein");
  for my $feat ($seq_obj->get_SeqFeatures) 
  {
    if($feat->primary_tag eq "CDS")
    {
      #print "primary tag: ", $feat->primary_tag, "\n";
      for my $tag ($feat->get_all_tags)
      {
        if($tag eq "locus_tag")
        {
          #print "  tag: ", $tag, "\n";
          for my $value ($feat->get_tag_values($tag))
          {
            #print $value, "\n";
            my $desc = join("\|","OrpC", join("_","ORPC", (split(/\_/,$value))[1] ));
           # print ">$desc\n";
            $seq_obj_out->display_id($desc);
          }
        }
        elsif($tag eq "translation")
        {
          for my $value ($feat->get_tag_values($tag))
          {
            #print $value, "\n";
            $seq_obj_out->seq($value);
          }
        }
      }
    }
  } # foreach feature
  $prot_out->write_seq($seq_obj_out);
} # while seq_obj

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
