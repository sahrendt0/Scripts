#!/usr/bin/perl
# Script mammoth.pl
# Description: Preprocessing for Mammoth structure alignment server 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.01.2013
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
my $usage = "Usage: mammoth.pl -i input\n";
die $usage if $help;

open(LIST,"<$input") or die "Can't open $input: $!\n";
while(my $file = <LIST>)
{
  chomp $file;
  open(PDB,"<$file");
  while(my $line = <PDB>)
  {
    chomp $line;
    next if($line !~ /^ATOM/);
    print $line,"\n";
  }
  close(PDB);
  print "TER\n";
}
close(LIST);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
