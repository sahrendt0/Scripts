#!/usr/bin/perl
# Script: getDomains.pl
# Description: Get regions of conserved TM helices 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.01.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use List::Util qw(min max);
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use Bio::Seq;
use Bio::SeqIO;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %TMHMM; # hash for parsing TMHMMfile (short format)
my %PHOBIUS; # hash for parsing PHOBIUSfile (short format)
my $seqIn_obj; # fasta file; Bio::SeqIO object
my $seqOut_obj; # fasta file; Bio::SeqIO object; for helices

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getDomains.pl -i input\nGet regions of conserved TM helices\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
%TMHMM = %{tmhmmParse("$input\.tmhmm")};
%PHOBIUS = %{phobiusParse("$input\.phobius")};
$seqIn_obj = Bio::SeqIO->new(-file => "$input\.fasta",
                             -format => "fasta");
$seqOut_obj = Bio::SeqIO->new(-file => ">$input\.out.fasta",
                              -format => "fasta");

while(my $seq_obj = $seqIn_obj->next_seq)
{
  my $seqID = $seq_obj->display_id;
  if($TMHMM{$seqID}{"PredHel"} != $PHOBIUS{$seqID}{"PredHel"})
  {
    next;
  }
  else
  {
    ## Get consensus of helices
    my $TMtopo = $TMHMM{$seqID}{"Topology"};
    my $PHtopo = $PHOBIUS{$seqID}{"Topology"};
    $TMtopo =~ s/^[oi]//;
    $PHtopo =~ s/^[oi]//;
    my @TMhelices = split(/[oi]/,$TMtopo);
    my @PHhelices = split(/[oi]/,$PHtopo);
    for(my $i=0;$i<scalar(@TMhelices);$i++)
    {
      print "$TMhelices{$i}\n";
      print "$PHhelices{$i}\n\n";
    }
  }
}
__END__
  my $newSeq = "";
  foreach my $helix (@helices)
  {  
    my ($start,$stop) = split(/-/,$helix);
    $start-=1;
    my $len = $stop-$start;
    print "\t$helix\t" if ($verb);
    print substr($seq_obj->seq,$start,$len) if ($verb);
    $newSeq .= substr($seq_obj->seq,$start,$len);
    print "\n" if ($verb);
  }
  my $newId = join("_",$seq_obj->display_id,"helices");
  my $newObj = Bio::Seq->new(-seq => $newSeq,
                             -display_id => $newId);
  $seqOut_obj->write_seq($newObj);
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
