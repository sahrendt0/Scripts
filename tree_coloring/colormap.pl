#!/usr/bin/perl
# Script: colormap.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.13.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my $colorfile = "colorlist";
my %colors;
my ($help,$verb);
my $line_width = 2;
GetOptions ('i|input=s' => \$input,
            'color=s'   => \$colorfile,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: colormap.pl -i input [--color]\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(COL,"<",$colorfile) or die "Can't open $colorfile\n";
while(my $line = <COL>)
{
  chomp $line;
  my ($RGB,$name,$group) = split(/\t/,$line);
  $colors{$group}{"R"} = $name;
  $colors{$group}{"Dendro"} = $RGB;
}
close(COL);

writeConfigs($input,"DendroColor.config","Dendro");
writeConfigs($input,"colorMap.config","R");

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub writeConfigs {
  my $infile = shift @_;
  my $outfile = shift @_;
  my $mode = shift @_;
  my $line_width=2;
  open(IN, "<", $infile) or die "Can't open $infile: $!\n";
  open(OUT,">",$outfile);
  if($mode eq "R")
  {
    print OUT join("\t","Taxa","Group","Color"),"\n";
  }
  elsif($mode eq "Dendro")
  { 
    print OUT join("\t","#Matching pattern","Keyword","Foreground color","Background color","Width"),"\n";
  }
  else
  {
    die "Unknown mode provided: $mode\n";
  }
  while(my $line = <IN>)
  {
    next if ($line =~ /^#/);
    chomp $line;
    my ($taxa,$order) = split(/\t/,$line);
    my $FG_col = $colors{$order}{$mode};
    my $BG_col = "";
    print OUT join("\t","complete",$taxa,$FG_col,$BG_col,$line_width),"\n" if ($mode eq "Dendro");
    print OUT join("\t",$taxa,$order,$FG_col),"\n" if ($mode eq "R");
  }
  close(IN);
  close(OUT);
}
