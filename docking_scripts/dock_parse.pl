#!/usr/bin/perl
# Script: dock_parse.pl
# Description: Parse an autodock .dlg file and prints free energy values (sorted) to _docking_results
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 6.25.14
##############
# Usage: dock_parse.pl -i dlg_file | -a
###################
# Entries are between "" and "________________________________________________________________________________"
###############
use strict;
use warnings;
use Getopt::Long;

#####-----Global Variables-----#####
my $input;
my $all;
my $dir = ".";
my ($help,$verb);
GetOptions ("i|infile=s" => \$input,
            "a|all"      => \$all,
            "h|help"     => \$help,
            "v|verbose"  => \$verb);

my $usage = "Usage: dock_parse.pl -i dlg_file | -a\n";
die $usage if($help);
die "No input\n$usage" if (!$input && !$all);

#####-----Main-----#####
my $entry_begin = "BEGINNING LAMARCKIAN GENETIC ALGORITHM DOCKING";
my $entry_end = "________________________________________________________________________________";
my $max_runs = 100;
my %runs;
my %info;
my @logs;

if($all)
{
  opendir(DIR,$dir);
  my @dirs = grep {-d "$dir/$_" && ! /^\.{1,2}$/} readdir(DIR); 
#  print join("\n",@dirs),"\n";
  close(DIR);
  foreach my $lig_dir (@dirs)
  {
    opendir(DIR,$lig_dir);
    my $log = (grep { /\.dlg$/ } readdir(DIR))[0];
    push (@logs,join("/",$dir,$lig_dir,$log));
    close(DIR);
  }
}
else
{
  push (@logs,$input);
}

#print join("\n",@logs),"\n";

foreach my $infile (@logs)
{
  #print $infile,"\n";
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
    }
    if ($read)
    {
      if ($line =~ m/^Run:\s+\d+\s\/\s\d+$/)
      { 
        $run = (split(/[\:|\/]/,$line))[1];
        $run =~ s/^\s+//;
        $run =~ s/\s+$//g;
      }
      if($line =~ m/Estimated Free Energy of Binding/)
      {
        $binding_energy = (split(/=/,$line))[1];
        $binding_energy =~ s/^\s+//;
        $binding_energy =~ s/\[$//;
        $binding_energy =~ s/\s+$//;
        $binding_energy = (split(/ /,$binding_energy))[0];      
      }
    }
    if (($line =~ m/^$entry_end$/) && ($run))
    {
      $read = 0;
      $runs{$run} = $binding_energy;
      last if ($run == $max_runs);
    }
  }
  close(IN);
  my @filename = split(/\//,$infile);
  #print join("-",@filename),"\n";
  my ($rec,$lig,$count,$ext) = split(/\_/,$filename[2]);
  my $outstream = ">$filename[0]/$filename[1]/$rec\_$lig\_$count\_docking\_results";

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
} # loop through dlg files


warn "Done.\n";
exit(0);
