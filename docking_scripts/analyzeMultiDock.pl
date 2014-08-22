#!/usr/bin/perl
# Script: analyzeMultiDock.pl
# Description: Summarizes the results of a batch docking run 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 07.09.2014
##################################
# Descend into Ligands dir
# collect all summary files
# output should be R-parsable; one file w/ columns as all results, sorted best to worst

use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Cwd;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $docking = "/home/sahrendt/Scripts/docking_scripts";
my %final;  # stores final data for free energy of binding (FEB)

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: analyzeMultiDock.pl -i input\nSummarizes the results of a batch docking run\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $pwd = getcwd;
my $receptor = (split(/\//,$pwd))[-1];
my $dir = "Ligands";
opendir(LIG,$dir);
my @lig_dirs = grep {-d "$dir/$_" && ! /^\.{1,2}$/} readdir(LIG);
closedir(LIG);
foreach my $subdir (@lig_dirs)
{
  my $logfile = "./$dir/$subdir/$receptor\_$subdir\_dock.dlg";
  if(-f $logfile)
  {
    print `perl $docking/dock_parse.pl -i $logfile`; 
  }
  else
  {
    print "Nope\n";
  }
}
#print join("\n",sort @lig_dirs),"\n";
opendir(LIG,$dir);
my @results = sort grep {/results$/} readdir(LIG);
closedir(LIG);

## Something wrong with this portion...
foreach my $result_file (@results)
{
  $result_file = "$dir/$result_file";
  open(my $fh,"<",$result_file) or die "Can't open $result_file: $!\n";
  my $ligand = (split(/\//,$result_file))[1];
  $ligand = (split(/\_\_/,$ligand))[0];
  my @binding;
  #print "$ligand\n";
  while (my $line = <$fh>)
  {
    next if ($line =~ /^#/);
    my ($run,$FEB) = split(/\t/,$line);
    #print $FEB,", ";
    push (@binding,$FEB);
  }
  close($fh);
  $final{$ligand} = \@binding;
}

#print Dumper \%final;
foreach my $key (sort keys %final)
{
  print $key,"\t";
  print join("\t",@{$final{$key}}),"\n"; 

}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
