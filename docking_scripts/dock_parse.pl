#!/usr/bin/perl
# Script: dock_parse.pl
# Description: Parse an autodock .dlg file
##############
# Usage: dock_parse.pl -i dlg_file
####
# Entries are between "" and "________________________________________________________________________________"
###############

use strict;
use warnings;
use Getopt::Long;

my $infile;
my $help = 0;
GetOptions ("i|infile=s" => \$infile,
            "h|help+"    => \$help);

if($help)
{
  print "Usage: dock_parse.pl -i dlg_file\n";
  exit
}

my $entry_begin = "BEGINNING LAMARCKIAN GENETIC ALGORITHM DOCKING";
my $entry_end = "________________________________________________________________________________";
my $max_runs = 100;
my %runs;
my %info;

open(IN,"<$infile") or die "Can't open file \"$infile\".\n";
my $read = 0;
my $run = 0;
my $binding_energy;
foreach my $line (<IN>)
{
  chomp $line;
  if ($line =~ m/\s+$entry_begin/)
  {
    $read = 1;
    #print "Start reading\n";
  }
  if ($read)
  {
    if ($line =~ m/^Run:\s+\d+\s\/\s\d+$/)
    { 
      #print "$line\t";
      $run = (split(/[\:|\/]/,$line))[1];
      $run =~ s/^\s+//;
      $run =~ s/\s+$//g;
      #print "$run\n";
    }
    if($line =~ m/Estimated Free Energy of Binding/)
    {
      $binding_energy = (split(/=/,$line))[1];
      #print "<$binding_energy>\n";
      $binding_energy =~ s/^\s+//;
      $binding_energy =~ s/\[$//;
      $binding_energy =~ s/\s+$//;
      #print "<$binding_energy>\n";
      $binding_energy = (split(/ /,$binding_energy))[0];      
      #print "<$binding_energy>\n";
      #$info{'Bind'} = $binding_energy;
    }
  }
  if (($line =~ m/^$entry_end$/) && ($run))
  {
    $read = 0;
    #print "Stop reading\n";
    #print $run,"\n";
    #print $binding_energy,"\n";
    $runs{$run} = $binding_energy;
    #print "$runs{$run}\n";
    last if ($run == $max_runs);
  }
}
close(IN);

print "$infile:\n";
print "Run\t";
print "Free Energy\t";
print "\n";
foreach my $key (sort {$a <=> $b} keys %runs)
{
  print "$key\t";
  print "$runs{$key}\t";
  print "\n";
}
