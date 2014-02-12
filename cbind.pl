#!/usr/bin/perl
# Script: cbind.pl
# Description: Like cbind() in R 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.31.2014
##################################
# For now, only 2 files
###########################
use warnings;
use strict;
use Getopt::Long;

#####-----Global Variables-----#####
my ($file1,$file2);
my ($help,$verb);
my %final;

GetOptions ('1=s'      => \$file1,
            '2=s'      => \$file2,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: cbind.pl -1 file2 -2 file2\n";
die $usage if $help;
die "No input.\n$usage" if ((!$file1) and (!$file2));

#####-----Main-----#####
open(F1,"<$file1") or die "Can't open $file1: $!\n";
open(F2,"<$file2") or die "Can't open $file2: $!\n";

while(my $line = <F1>)
{
  chomp $line;
  my ($key,$val) = split(/\t/,$line);
  $final{$key}{'F1'} = $val;
}
while(my $line = <F2>)
{
  chomp $line;
  my ($key,$val) = split(/\t/,$line);
  $final{$key}{'F2'} = $val;
}
close(F1);
close(F2);

print "PFID\t$file1\t$file2\n";
foreach my $key (sort keys %final)
{
  print $key,"\t";
  if(exists($final{$key}{'F1'}))
  {
    print $final{$key}{'F1'};
  }
  else
  {
    print 0;
  }
  print "\t";
  if(exists($final{$key}{'F2'}))
  {
    print $final{$key}{'F2'};
  }
  else
  {
    print 0;
  }
  print "\n";
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
