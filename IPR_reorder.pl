#!/usr/bin/perl
# Script: IPR_reorder.pl
# Description: Used in MG_HMM workflow 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 02.27.2014
##################################
use warnings;
use strict;
use Getopt::Long;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: IPR_reorder.pl -i input\nOutput to STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(IN,"<$input") or die "Can't open $input: $!\n";
while(my $line = <IN>)
{
  chomp $line;
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;
  my ($count,$ID,$desc) = split(/\s+/,$line);
  $ID = (split(/\./,$ID))[0];
  print "$ID;$desc\t$count\n";
}
close(IN);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
