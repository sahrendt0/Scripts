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
my $num = 0;
open(NO_CDS,">no_cds");
open(MULT_CDS,">mult_cds");
while(my $seq_obj = $seq_io->next_seq)
{
  my $locus = $seq_obj->display_id;
  my $has_CDS=0;
  for my $feat ($seq_obj->get_SeqFeatures) 
  {
    if($feat->primary_tag eq "CDS")
    {
      $has_CDS++;
      if($has_CDS > 1)
      {
        warn "Multiple CDS at $locus\n";
        print MULT_CDS $locus,"\n";
      }
      my $seq_obj_out = Bio::Seq->new(-alphabet => "protein");
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
      $prot_out->write_seq($seq_obj_out);
    } # if CDS
  } # foreach feature
  if(!$has_CDS)
  {
    warn "No CDS for $locus\n";
    print NO_CDS $locus,"\n";
  }
 $num++;
} # while seq_obj
close(NO_CDS);
close(MULT_CDS);
warn "$num\n";
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
