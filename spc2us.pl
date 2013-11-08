#!/usr/bin/perl -w
# Script: spc2us.pl
# Description: renamer script used for replacing spaces w/ underscores in filenames
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 2.11.11
# Usage: spc2us.pl

use strict;

## Use current directory
my $dir = ".";

## Grab all filenames
opendir(DIR,$dir);
my @files = grep { /\.\w*$/} readdir(DIR);
closedir(DIR);

## Unless the filename is "." or "..", or has no spaces, replace the spaces w/ underscores
foreach my $file (@files)
{
  if(($file !~ /^\.+$/) && ($file =~ m/.* .*/))
  {
    print $file,"\n";
    my $new = $file;
    $new =~ s/ /\_/g;
    rename($file,$new);
    print $new,"\n";
  }
}

