#!/usr/bin/perl
# Script: trin2gaf.pl
# Description: Maps trinotate file to GO association file for GOSlim 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 07.25.2014
##################################
#
# Col	Content		Required	Ex
# 1	DB		y		UniProtKB
# 2	DB Obj ID	y		P12345
# 3	DB Obj symbol	y		PHO3
# 4			n		NOT
# 5	GO ID		y		GO:0003993
###################################
# Tasks
#  [ ] get taxID from species (col 13)
#  [ ] get PMID reference from best blast hit (col 6)
#  [ ] get namespace of GO ID (col 9): "C", "P", "F"
#  [x] use col 1 for col 15
######################################
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
my $usage = "Usage: trin2gaf.pl -i input\nMaps trinotate file to GO association file for GOSlim\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh,"<",$input) or die "Can't open $input: $!\n";
while (my $line = <$fh>)
{
  next if($line =~ /^#/);
  chomp $line;
  my($gene_id, $transcript_id, $top_blX, $RNAMMER, $prot_id, $prot_coords, $top_blP, $PFAM, $SigP, $TMHMM, $eggnog, $GO) = split(/\t/,$line);
  if($GO ne ".")
  {
    my @go_terms = split(/\`/,$GO);
    foreach my $goID (@go_terms)
    {   
      my($ID,$type,$desc) = split(/\^/,$goID);
      
      my @gaf_line = qw(. . . . . . . . . . . . . . . . .);

      # set up DB fields
      $gaf_line[0] = "UniProtKB";
      $gaf_line[14] = $gaf_line[0];
    #  my $DB_obj = split(/\^/,$top_blX);
      my($db,$db_obj_id,$db_obj_sym) = split(/\|/, (split(/\^/,$top_blX))[0]);
      $gaf_line[1] = $db_obj_id;
      $gaf_line[2] = $db_obj_sym; 
      $gaf_line[4] = $ID;
      $gaf_line[8] = uc((split(//, (split(/\_/,$type))[1] ))[0]);
      print "@gaf_line\n";
    }
  }
}
close($fh);



warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getTaxID{
}
