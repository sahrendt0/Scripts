#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $input;
my $help=0;

GetOptions ("i|input=s" => \$input,
            "h|help+"   => \$help);

if($help)
{
  print "Usage: getModels.pl -i best_hits\n";
  exit;
}

## Find the files
open(IN,"<$input") || die "Can't open $input\n";
foreach my $line (<IN>)
{
  chomp $line;
  my ($file,$mod_score,$dope_score) = split(/\t/,$line);
  print `find "." -name $file >> final_files`;
}
close(IN);

## Get the files
print `mkdir final`;
open(FIN,"<final_files");
foreach my $line (<FIN>)
{
  chomp $line;
  print `cp $line ./final`;
}
close(FIN);
