#!/usr/bin/perl
# Script: parseContacts.pl
# Description: Parse Google Contacts csv file 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.21.2014
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
my $usage = "Usage: parseContacts.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(IN,"<$input");
while(my $line = <IN>)
{
  chomp $line;
  my @data = split(/,/,$line);
  #1,3,18-24 googleContacts.csv
  print "$data[0] $data[2]\t";
  for(my $i = 17; $i < 24; $i++)
  {
    print "$data[$i]\t" if ($data[$i]);
  }
  print "\n";
}
close(IN);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
