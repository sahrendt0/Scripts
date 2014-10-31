#!/usr/bin/perl
# Script: tsv2latex.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.20.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my @data;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: tsv2latex.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh, "<", $input) or die "Can't open $input: $!\n";
foreach my $line (<$fh>)
{
  chomp $line;
  $line =~ s/#/\\#/g;
  $line =~ s/>=/\$\\geq\$/g;
  $line =~ s/%/\\%/g;
  my @data = split(/\t/,$line);
  print join(" & ",@data);
  print "\\\\ \\hline\n";
}
close($fh);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
