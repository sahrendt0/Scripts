#!/usr/bin/perl
# Script dock_summ_all.pl
# Description: Averages the best 5 docking conformations and presents a table of scores. TO BE IMPLEMENTED: Creates pdb files for top 5 conformations 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.02.2013
##################################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;

#####-----Global Variables-----#####
my $dir = ".";
my ($help,$verb);
my %data;  # Nested hashes: {receptor}{ligand} is an array with [avg][1][2][3][4][5] scores
my $best_scores = 5;
my @ligands;
my $master_out = "covalent_docking_summary";

GetOptions ('d|dir=s' => \$dir,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: dock_summ_all.pl [-d dir]\n";
die $usage if $help;

#####-----Main-----#####
## Check for _docking_summary files
opendir(DIR,$dir);
my @dir_list = grep {-d && /\w+/} readdir(DIR);
closedir(DIR);

foreach my $dock_dir (@dir_list)
{
  if($verb){print $dock_dir,"\n";}
  opendir(DIR,$dock_dir);
  if(my $summ_file = ( grep {/\_docking\_summary/} readdir(DIR)  )[0])
  {
    if($verb)
    {
      print "\t$summ_file\n";
      print `head -2 $dock_dir/$summ_file`;
    }
    open(SUMM,"<$dock_dir/$summ_file") or die "Can't open $summ_file: $!\n";
    my (@header,@FE_scores);
    my $lc = 0;
    while($lc < $best_scores)
    {
      my $line = <SUMM>;
      chomp $line;
      next if($line =~ /^#/);

      my @dat = split(/\t/,$line);
      if($line =~ /A1/)
      {
        @header = @dat;
        @ligands = @header;
      }
      else
      {
        @FE_scores = @dat;
        for(my $i=0;$i<scalar(@dat);$i++)
        {
          if($verb){print "$i: $dock_dir\t$header[$i]\t$FE_scores[$i]\n";}
          ${$data{$dock_dir}{$header[$i]}}[($lc+1)] = $FE_scores[$i];
          if(!${$data{$dock_dir}{$header[$i]}}[0])
          {
            ${$data{$dock_dir}{$header[$i]}}[0] = $FE_scores[$i];
          }
          else
          {
            ${$data{$dock_dir}{$header[$i]}}[0] = sprintf("%.2f",avgAr(\@{$data{$dock_dir}{$header[$i]}}));
          }
        }
        $lc++;
      }
    } # while()
    close(SUMM);
  }
  closedir(DIR);
} 

if($verb){print Dumper \%data;}

open(COV,">$master_out");
print COV join("\t","Receptor",sort(@ligands)),"\n";
foreach my $rec (sort keys %data)
{
  print COV "$rec\t";
  foreach my $lig (sort keys $data{$rec})
  {
    print COV ${$data{$rec}{$lig}}[0],"\t";
  }
  print COV "\n";
}
close(COV);
if($verb){print `cat $master_out`;}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub avgAr
{
  my @ar = @{$_[0]};
  my $sum = 0;
  foreach my $item (@ar)
  {
    $sum += $item;
  }
  return $sum / scalar(@ar);
}
