#!/usr/bin/perl
# Script: dock_parse.pl
# Description: Parse an autodock .dlg file and prints free energy values (sorted) to _docking_results
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.27.13
##############
# Usage: dock_parse.pl -i dlg_file
###################
# Entries are between "" and "________________________________________________________________________________"
###############
use strict;
use warnings;
use Getopt::Long;

#####-----Global Variables-----#####
my $infile;
my ($help,$verb);
GetOptions ("i|infile=s" => \$infile,
            "h|help"     => \$help,
            "v|verbose"  => \$verb);

my $usage = "Usage: dock_parse.pl -i dlg_file\n";
die $usage if($help);
die "No input\n$usage" if (!$infile);

#####-----Main-----#####
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
my @filename = split(/\//,$infile);
my ($rec,$lig,$ext) = split(/\_/,$filename[2]);
my $outstream = ">$filename[0]/$filename[1]/$rec\_$lig\_docking\_results";

if($verb)
{
  $outstream = ">&STDOUT";
}

open(OUT,$outstream);
print OUT "#$infile:\n";
print OUT "#Run\t";
print OUT "Free Energy\t";
print OUT "\n";
foreach my $key (sort {$runs{$a} <=> $runs{$b}} keys %runs)
{
  print OUT "$key\t";
  print OUT "$runs{$key}\t";
  print OUT "\n";
}
close(OUT);
warn "Done.\n";
exit(0);
