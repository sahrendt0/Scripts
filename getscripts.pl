#!/usr/bin/perl -w
# Script: getscripts.pl
# Description: Produces README.md containing all of the custom scripts in ~/scripts
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.15.13
#       v.1.0
#       v.1.1 Add support for R or C/C++ files
#       v.1.2 Change home dir
#       v.1.3 Add support for Ruby or Python files
#       v.1.5 updated for Github & added support for .pm files
#############################
# Usage: getscripts.pl
############################

use strict;

my $dir = ".";
my $ext = "[pl|c|R|rb|py|pm]";

my @scripts = glob '*.{pl,c,R,rb,py,pm}';
=begin COMMENT
opendir(DIR,$dir) or die "Can't open $dir\n";
my @scripts = grep { /\.$ext$/} readdir(DIR);
close(DIR);
=cut
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
