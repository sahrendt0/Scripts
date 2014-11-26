#!/usr/bin/perl
# Script: colormap.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.13.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my $colorfile = "colorlist";
my %colors;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'color=s'   => \$colorfile,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: colormap.pl -i input [--color]\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(COL,"<",$colorfile) or die "Can't open $colorfile\n";
while(my $line = <COL>)
{
  chomp $line;
  my ($val,$key) = split(/\t/,$line);
  $colors{$key} = $val;
}
close(COL);

open(IN, "<", $input) or die "Can't open $input: $!\n";
print "#Matching pattern\tKeyword\tForeground color\n";
while(my $line = <IN>)
{
  next if ($line =~ /^#/);
  chomp $line;
  my ($taxa,$order) = split(/\t/,$line);
  print join("\t","complete",$taxa,$colors{$order},$line_width),"\n";
}
close(IN);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
