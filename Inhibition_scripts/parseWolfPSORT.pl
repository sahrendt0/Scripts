#!/usr/bin/perl
# Script: parseWolfPSORT.pl
# Description: Parses WolfPSort output files 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.16.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my %predictions;
my $id;
my @locs = qw(extr golg E.R.);
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'id=s'      => \$id,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: parseWolfPSORT.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh,"<",$input) or die "Can't open $input: $!\n";
while(my $line = <$fh>)
{
  next if($line =~ /^#/);
  chomp $line;
  my ($gene,@data) = split(/ /,$line);
  for(my $i=0;$i<scalar(@data);$i++)
  {
    push (@{$predictions{$gene}{"Loc"}},$data[$i]) if($i%2 == 0);
    push (@{$predictions{$gene}{"Score"}},$data[$i]) if($i%2 != 0);
    
  }
}
close($fh);

foreach my $key (sort keys %predictions)
{
  my $top_pred = $predictions{$key}{"Loc"}[0];
  print "$key\t$top_pred\n" if(inArray($top_pred,\@locs));
}

if($id)
{
  print Dumper $predictions{$id},"\n";
}
print Dumper \%predictions if $verb;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub inArray
{
  my $item = shift @_;
  my @array = @{shift @_};
  my $result = 0;
  foreach my $ar (@array)
  {
    $result = 1 if($item eq $ar);
  }
  return $result;
}
