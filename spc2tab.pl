#!/usr/bin/perl
# Script: spc2tab.pl
# Description: Replaces multispace-delim files to tsv files 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.08.2014
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
my $usage = "Usage: spc2tab.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $filename = (split(/\./,$input))[0];

open(my $in,"<",$input) or die "Can't open $input: $!\n";
open(my $out,">","$filename.tsv");
while(my $line = <$in>)
{
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;
  if($line =~ /^#/)
  {
    print $out $line,"\n";
  }
  else
  {
    chomp $line;
    my @data = split(/\s{2,}/,$line);
    print $out join("\t",@data),"\n";
  }
}
close($in);
close($out);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
