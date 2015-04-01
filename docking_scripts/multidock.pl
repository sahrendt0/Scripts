#!/usr/bin/perl
# Script: multidock.pl
# Description: sets up automated docking for multiple chemicals 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.22.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $dir = ".";
GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: multidock.pl\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####

## Step 0: Make individual directories for each compound
#     and convert the .sdf files to .mol2 files
opendir(DIR,$dir);
my @compounds = sort grep {/\.sdf$/} readdir(DIR);
closedir(DIR);
opendir(DIR,$dir);
my ($pdbfile) = grep {/\.pdb$/} readdir(DIR);
closedir(DIR);
print $pdbfile,"\n";


chomp @compounds;
print `mkdir Ligands`;
foreach my $cmpd (@compounds)
{
  next if ($cmpd =~ /sim/); # ignore the original "sim" file, since it may be in the current dir
  print $cmpd,"\n";
  my @tmp = split(/\./,$cmpd);
  pop @tmp;
  my $dirname = join(".",@tmp);
  print `mkdir $dirname`;
  print `cp $cmpd ./Ligands`;
  print `mv $cmpd $dirname`;
  print `babel -i sdf ./$dirname/$cmpd -o mol2 ./$dirname/$dirname\.mol2`;
  print `ln -s ../$pdbfile ./$dirname/$pdbfile`;
  #print $dirname,"\n";
  #print `mkdir $dirname`;
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
