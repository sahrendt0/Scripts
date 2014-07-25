#!/usr/bin/perl
# Script: score_rank.pl
# Description: Run through parselog.pl and rank.pl

use warnings;
use strict;
use Getopt::Long;

my $input;
my $help=0;
my $all;
GetOptions ("i|input=s" => \$input,
            "a|all=s"   => \$all,
            "h|help+"   => \$help);

if($help)
{
  print "Usage: score_rank.pl -i inputlog\n";
  exit;
}

if($all)
{
  open(ALL,"<$all") || die "Can't open $all\n";
  foreach my $file (<ALL>)
  {
    chomp $file;
    $input = (split(/\.l/,$file))[0];
    print $input,"\n";
    print `parselog.pl -i $input\.log > $input\.scores`;
    print `myrank.pl -i $input\.scores > $input\.rank`;
    #print `less $input\.rank`;
  }
  close(ALL);
}
else
{
    print $input,"\n";
    print `parselog.pl -i $input\.log > $input\.scores`;
    print `myrank.pl -i $input\.scores > $input\.rank`;
    print `less $input\.rank`;
}
