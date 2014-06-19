#!/usr/bin/perl
# Script: rankCompare.pl
# Description: Compares ranks from rankAbund.pl 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 06.04.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use Data::Dumper;

#####-----Global Variables-----#####
my ($UNITE, $merged);
my (%UNITE_hash, %Merged_hash);
my ($help,$verb);
my $input;
my @static = qw(MX7.405868 MX5.405794 KJ10sa.405857);
my @dynamic = qw(IK1uk.405761 Reg31.405860 BH8.405862);

GetOptions ('i|input=s' => \$input,
            'u|unite=s' => \$UNITE,
            'm|merged=s' => \$merged,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: rankCompare.pl -i input\nCompares ranks from rankAbund.pl\n";
die $usage if $help;
#die "No input.\n$usage" if (!$input);

#####-----Main-----#####
%UNITE_hash = getTax($UNITE);
%Merged_hash = getTax($merged);

## UNITE top 5
## Static locations
print "static\n";
topFive(\%UNITE_hash,\%Merged_hash,\@static);
print "dynamic\n";
topFive(\%UNITE_hash,\%Merged_hash,\@dynamic);

#foreach my $sampleID (sort keys %UNITE_hash)
#{
#  for(my $i=0;$i<scalar (@{$UNITE_hash{$sampleID}{"Tax"}});$i++)
#  {
#    if($UNITE_hash{$sampleID}{"Tax"}[$i] ne $Merged_hash{$sampleID}{"Tax"}[$i])
#    {
#      print $sampleID,"\n";
#    }
#  }
#}

#print Dumper \%UNITE_hash;
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub topFive {
  my $hash1 = shift @_;
  my $hash2 = shift @_;
  my $keys = shift @_;

  foreach my $id (@{$keys})
  {
    print $id,"\n";
    for (my $i=0;$i<5;$i++)
    {
      print $hash1->{$id}{"Tax"}[$i],"\t";
      print $hash1->{$id}{"Score"}[$i],"\t";
      print $hash2->{$id}{"Tax"}[$i],"\t";
      print $hash2->{$id}{"Score"}[$i],"\n";
    }
  }
}

sub getTax {
  my $file = shift @_;
  my %hash;
  open(my $uh,"<",$file) or die "Can't open $file: $!\n";
  while(my $line = <$uh>)
  {
    chomp $line;
    my ($id,$tax,$score) = split(/\t/,$line);
    push (@{$hash{$id}{"Tax"}}, $tax);
    push (@{$hash{$id}{"Score"}}, $score);
  }
  close($uh);
  return %hash;
}
