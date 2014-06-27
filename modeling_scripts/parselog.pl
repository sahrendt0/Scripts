#!/usr/bin/perl
# Script: parselog.pl
# Description: Parses a modeller logfile for scores
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 8.14.13
#######################
# Usage: parselog.pl -i logfile
######################
use warnings;
use strict;
use Getopt::Long;

my $input;
my $help = 0;
GetOptions('i|input=s' => \$input,
           'h|help+' => \$help);

if($help)
{
  print "Usage: parselog.pl -i logfile\n";
  exit;
}

my $log = 0; #flag for printing lines

open (IN,"<$input") || die "Can't open $input, stopped";
foreach my $line (<IN>)
{
  if($line =~ m/^>> Summary/)
  {
    $log = 1;
  }
  if($line =~ m/^\s+$/)
  {
    $log = 0;
  }
  if($log)
  {
    print $line;
  }
}
close(IN);
