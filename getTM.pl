#!/usr/bin/perl
# Script: getTM.pl
# Description: Parses the 6-9 TM sequences from a TMHMM results file 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 09.17.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getTM.pl -i input\nParses the 6-9 TM sequences from a TMHMM results file\nCreates individual files for each architecture\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh, "<", $input) or die "Can't open $input: $!\n";
my $filename = (split(/\./,$input))[0];

open(OUTALL,">","$filename\_all.accnos");
open(OUTSIX,">","$filename\_6.accnos");
open(OUTSEVEN,">","$filename\_7.accnos");
open(OUTEIGHT,">","$filename\_8.accnos");
open(OUTNINE,">","$filename\_9.accnos");

while(my $line = <$fh>)
{
  chomp $line;
  my($seq_id,$len,$expAA,$first60,$predHel,$topology) = split(/\t/,$line);
  $predHel = (split(/=/,$predHel))[1];
  if($predHel >= 6 && $predHel <= 9)
  {
    print OUTALL $seq_id,"\n";
    print OUTSIX $seq_id,"\n" if($predHel == 6);
    print OUTSEVEN $seq_id,"\n" if($predHel == 7);
    print OUTEIGHT $seq_id,"\n" if($predHel == 8);
    print OUTNINE $seq_id,"\n" if($predHel == 9);
  }
}

close($fh);
close(OUTALL);
close(OUTSIX);
close(OUTSEVEN);
close(OUTEIGHT);
close(OUTNINE);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
