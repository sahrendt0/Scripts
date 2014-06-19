#!/usr/bin/perl
# Script: rankAbund.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 06.04.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %hash;
GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: rankAbund.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh,"<",$input) or die "Can't open $input: $!\n";
my @hash_keys;
while(my $line = <$fh>)
{
  chomp $line;
  if($line =~ /^Taxon/)
  {
    @hash_keys = split(/\t/,$line);
    shift @hash_keys;
  }
  else
  {
    my ($level,@abund) = split(/\t/,$line);
    if($level =~ /Ascomycota/)
    {
      for(my $i=0;$i<scalar(@hash_keys); $i++)
      {
        $hash{$hash_keys[$i]}{$level} = $abund[$i];
      }
    }
  }
}
close($fh);

#print Dumper \%hash;
foreach my $key (sort keys %hash)
{
  my $count = 0;
  #print $key;
  foreach my $level (sort {$hash{$key}{$b} <=> $hash{$key}{$a} } keys %{$hash{$key}})
  {
    print $key,"\t",$level,"\t",$hash{$key}{$level},"\n" if($count < 5);
    $count++;
  }
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
