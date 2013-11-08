#!/usr/bin/perl
# Script: dock_summ.pl
# Description: Summarizes all of the *_docking_results files in the current directory
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 8.27.13
###########################################
# Usage: dock_summ.pl
###########################################
use warnings;
use strict;
use Getopt::Long;

my $help = 0;
my $dir = ".";

GetOptions ("h|help+" => \$help,
            "d|dir=s" => \$dir);

if($help)
{
  print "Usage: dock_summ.pl [-d dir]\n";
  exit;
}

opendir(DIR,$dir);
my @dir_list = grep {-d && /\w+/} readdir(DIR);
my @file_list = grep {/\_docking\_results$/} readdir(DIR);
closedir(DIR);

if(scalar @file_list == 0)
{
  print join(" ",@dir_list),"\n";
  foreach my $new_dir (@dir_list)
  {
    opendir(D,"./$new_dir");
    my @files = grep {/\.dlg$/} readdir(D);
    closedir(D);
    if(scalar @files)
    {
      print $files[0],"\n";
      my $logfile = $files[0];
      my ($rec,$lig,$dock) = split(/\_/,$logfile);
      my $res = "$lig\_docking\_results";
      print `~/Scripts/dock_parse.pl -i $dir/$new_dir/$logfile > $res\n`;
      push (@file_list,$res);
    }
  }
}
print "@file_list\n";

my $sum_file = "docking_summary";
my $num_runs = 100;
my %scores;

foreach my $file (@file_list)
{
  #print $file,"\n";
  open(IN,"<$file") || die "Can't open file $file.\n";
  my $lc = 0;
  my $ligand;
  my %FEnergy;
  foreach my $line (<IN>)
  {
    #print $lc,"\n";
    chomp $line;
    #print $line,"\n";
    if($lc == 0)
    {
      $ligand = (split(/\_/, (split(/\//,$line))[2] ))[1];
      #print "$ligand\n";
    }
    else
    {
      if($lc > 1)
      {
        my($run,$FE) = split(/\s+/,$line);
        $FEnergy{$run} = $FE;
      }
    }
    $lc++;
  }
  close(IN);
  $scores{$ligand} = \%FEnergy;
}

#print $scores{'A4'}{7},"\n";

my @ligands = sort keys %scores;

open(SUM,">$sum_file");
print SUM "Run\t";
print SUM join("\t",@ligands);
print SUM "\n";
foreach my $run (1..$num_runs)
{
  print SUM $run,"\t";
  foreach my $lig (@ligands)
  {
    print SUM $scores{$lig}{$run},"\t";
  }
  print SUM "\n";
}
close(SUM);
