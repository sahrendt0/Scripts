#!/usr/bin/perl
# Script: /home/sahrendt/Scripts/docking_scripts/batch_docking.pl
# Description: Batch docking for multiple ligand; sets up a bunch of shell scripts 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 05.23.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my ($input,$abbr);
my ($help,$verb);
my $ligbase;
GetOptions ('i|input=s' => \$input,
            'a|abbr=s'  => \$abbr,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: /home/sahrendt/Scripts/docking_scripts/batch_docking.pl -i receptor_name -a abbr\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
opendir(my $cdh,".");
while (defined(my $name = readdir $cdh))
{
  next if $name =~ /^\.\.?+$/;
  next unless -d $name;
  next if $name !~ /\d{3}/;
  print "$name\n";
  opendir(my $ldh,"$name");
  my $ligbase = (grep {/\.sdf$/} readdir($ldh))[0];
  closedir($ldh);
  $ligbase = getFilename($ligbase); 
  print `docking_workflow.pl -l $ligbase -la $ligbase -r $input -ra $abbr -g $abbr\_grid_ref.gpf -s`;
  print `mv $abbr\_$ligbase\.sh $name`;
}
closedir($cdh);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getFilename
{
  my $fullname = shift @_;
  my @tmp = split(/\./,$fullname);
  pop @tmp;
  return join(".",@tmp);
}
