#!/usr/bin/perl
# Script: cbind.pl
# Description: Like cbind() in R 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.21.2014
##################################
# argument is comma-separated list of files
###########################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;

#####-----Global Variables-----#####
my $files;
my ($help,$verb);
my %final;

GetOptions ('--input=s' => \$files,
            'h|help'    => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: cbind.pl --input file1,file2[,file3,file4,...]\n";
die $usage if $help;
die "No input.\n$usage" if (!$files);

#####-----Main-----#####
chomp $files;
my @file_list = split(/,/,$files);
for (my $i=0; $i < scalar (@file_list); $i++)
{
  open(FH,"<",$file_list[$i]) or die "Can't open $file_list[$i]: $!\n";
  my @file_headers;
  while(my $line = <FH>)
  {
    chomp $line;
    my ($key,@vals) = split(/\t/,$line);
    if ($line =~ /^Org/)
    {
      @file_headers = @vals;
    }
    else
    {
#      print Dumper \@file_headers;
      $final{$key}{$i}{"Headers"} = join(",",@file_headers);
      $final{$key}{$i}{"Data"} = join(",",@vals);
    }
  }
  close(FH);
}

#print Dumper \%final;
my $test = "Wseb";
print $test,"\n";
print Dumper $final{$test};


warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
