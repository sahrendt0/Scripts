#!/usr/bin/perl
# Script: FM_ZygoAnalysis.pl
# Description: Specific script for analysis of Zygomycete run 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.11.2014
##################################
use warnings;
use strict;
use Getopt::Long;

#####-----Global Variables-----#####
my $input;
my $textfile;
my %fm_data;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            't|text=s'  => \$textfile,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: FM_ZygoAnalysis.pl -i input -t textfile\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);
die "No textfile.\n$usage" if (!$textfile);

#####-----Main-----#####
open(HASH,"<$textfile") or die "Can't open $textfile: $!\n";
while(my $line = <HASH>)
{
  chomp $line;
  my ($key,$val) = split(/\t/,$line);
  $fm_data{$key} = $val;
}
close(HASH);

open(IN,"<$input") or die "Can't open $input: $!\n";
while(my $line = <IN>)
{
  chomp $line;
  if($line =~ /^Org/)
  {
    my $new_line = reformatLine($line);
    print $new_line,"\n";
  }
  else
  {
    print $line,"\n";
  }
}

close(IN);
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub reformatLine
{
  my $line = shift @_;
  my @data = split(/\t/,$line);
  my @new_data;
  #my $d=0;
  foreach my $dat (@data)
  {
    if($dat ne "Org")
    {
      $dat = (split(/\|/,$dat))[2];
      if(exists $fm_data{$dat}){$dat = $fm_data{$dat};}
    }
    #print "$d: $dat\n";
    #$d++;
    push @new_data,$dat;
  }
  my $new_line = join("\t",@new_data);
  return $new_line;
}
