#!/usr/bin/perl
# Script: getAllComplex.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.26.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Cwd;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getAllComplex.pl -i input\n\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
opendir(DIR,".");
my @dirs = sort grep { /^LIG_\d\d\d$/ } readdir(DIR);
closedir(DIR);

print join("\n",@dirs),"\n";
my $orig_cwd = cwd;
foreach my $dir (@dirs)
{
  opendir(LIGDIR,$dir);
  my $log = (grep { /\.dlg$/ } readdir(LIGDIR))[0];
  $log = (split(/\./,$log))[0];
  chdir "$dir";
   print `pwd` if $verb;
  print `getComplex.sh $log`;
  chdir "$orig_cwd";
  print `pwd` if $verb;
  close($dir);
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
