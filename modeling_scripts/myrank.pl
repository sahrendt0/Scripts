#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $input;
my $help = 0;
GetOptions ("i|input=s" => \$input,
            "h|help+"   => \$help);

if($help)
{
  print "Usage: rank.pl -i scorefile\n";
  exit;
}

my (@mod,@pdf,@DOPE);
open(IN,"<$input") || die "Can't open $input\n";
foreach my $line (<IN>)
{
  chomp $line;
  next if ($line =~ m/^>/);
  next if ($line =~ m/^-/);
  next if ($line =~ m/^F/);
  print "$line\n";
  my ($model,$molPDF,$DOPE) = split(/\s+/,$line);
  push @mod,$model;
  push @pdf,$molPDF;
  push @DOPE,$DOPE;
}
close(IN);

my @pdf_scores = &Scores(@pdf);
my @dope_scores = &Scores(@DOPE);

my $min = 1000; # some high number which is vastly greater than what we expect for the sum of the ranks
my $min_counter = -1;
my $i = 0;
my $mult_models = 0; # if there are multiple models with the same min score
while ($i < scalar @mod)
{
  print "$mod[$i]\t$pdf_scores[$i]\t$dope_scores[$i]\n";
  if(($pdf_scores[$i]+$dope_scores[$i]) < $min)
  {
    $min = ($pdf_scores[$i]+$dope_scores[$i]);
    $min_counter = $i;
  }
  if(($pdf_scores[$i]+$dope_scores[$i]) < $min)
  {
    $mult_models++;
  }
  $i++;
}
open(OUT,">>total_rank");
{
  if($mult_models)
  {
    print OUT "*";
  }
  print OUT "$mod[$min_counter]\t$pdf_scores[$min_counter]\t$dope_scores[$min_counter]\n";
}
close(OUT);

sub Scores {
  my @ar = @_;
  my @sar = sort {$a <=> $b} @ar;
  my @r;  
  foreach my $num (@ar)
  {
    my $c = 0;
    while($num != $sar[$c])
    {
      $c++;
    }
    push @r,$c;
  }
  return @r;
}
