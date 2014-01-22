#!/usr/bin/perl
# Script: getscripts.pl
# Description: Produces README.md containing all of the custom scripts in ~/scripts
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.11.13
#       v.1.0
#       v.1.1 Add support for R or C/C++ files
#       v.1.2 Change home dir
#       v.1.3 Add support for Ruby or Python files
#       v.1.5 updated for Github & added support for .pm files
#############################
# Usage: getscripts.pl
############################
# - Basically only look for lines that start with the comment character ("#" or "*"), a space, and the word "Description".
# - This is ensured if all new scripts are created using mkpl.pl or mkpm.pl; otherwise this is up to the script author
# - These scripts (mkpl.pl and mkpm.pl) have two of these lines: one for being themselves perl scripts, 
#     and another that they write to scripts/modules they create.
# - Write out the main description (ie the first one) to README.md (for github)
############################
use strict;
use warnings;

my $dir = ".";
my $ext = "[pl|c|R|rb|py|pm]";

my @scripts = glob '*.{pl,c,R,rb,py,pm}';
@scripts = sort @scripts;
my $len = 0;
open(OUT,">README.md");

## Print HEADER
foreach my $script (@scripts)
{
  print $script,"\n";
  print OUT $script;
  #print "$script\n";	
  $len = length($script);
  #print "($len)";
  if(($len%2)==0)
  {
    while($len < 24)
    {
      print OUT ". ";
      $len+=2;		
    }
  }
  else
  {
    while($len < 23)
    {
      print OUT " .";
      $len+=2;
    }
    print OUT " ";
  }
  open(IN,"<$dir/$script") or die "Can't open $dir/$script..\n";
  my $dline = 0; # counter for how many description lines are in a file
                 # pretty much just used for the "mkpl" and "mkpm" scripts
  foreach my $line (<IN>)
  {
    chomp($line);
    next if($line !~ m/^[#|*]+ Description/i);
    $dline++;
    if($dline == 1){print OUT substr($line,15);}
  }
  print OUT "<br>\n";
  close(IN);
}
close(OUT);
