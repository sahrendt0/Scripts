#!/usr/bin/perl
# Script: bibWeb.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.26.2015
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
my $usage = "Usage: bibWeb.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(IN,"<",$input) or die "Can't\n";
while(my $line = <IN>)
{
  chomp $line;
  my($code,$site,$tex) = split(/\t/,$line);
  print '@online{'.$code.',
   author = {},
   title = {'.$code.' source},
   url = {'.$site.'}
}'."\n";
}
close(IN);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
