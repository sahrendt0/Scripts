#!/usr/bin/perl
# Script: toLatex.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 09.13.2014
##################################
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my %results;  # contains all protein domains, keys as prot IDs w/ multiple domains
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: toLatex.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

my $filename = (split(/\./,$input))[0];

open(my $fh, "<", $input);

while(my $line = <$fh>)
{
  next if ($line !~ /Pfam/);
  chomp $line;
  my ($protID,$MD5,$len,$analysis,$sigID,$desc,$start,$stop,$score,$status,$date) = split(/\t/,$line);
  $results{$protID}{'Len'} = $len;
  push(@{$results{$protID}{'Dom'}}, join(":",$sigID,$start,$stop));
}

close($fh);

if($verb)
{
#  print Dumper \%results;
  foreach my $key (sort keys %results)
  {
    foreach my $dom(@{$results{$key}{'Dom'}})
    {
      print "$key\t$dom\n";
    }
  }
}
else
{
  ## Write to .tex file
  open(my $out,">","$filename\.tex");

  writePreamble($out,$filename);
  foreach my $key (sort keys %results)
  {
    print $out "\\begin{pmbdomains}[name=$key,x unit=0.2mm,residues per line=1000]{$results{$key}{'Len'}}\n";
    foreach my $domain (@{$results{$key}{'Dom'}})
    {
      my ($dID,$dStart,$dStop) = split(/:/,$domain);
      print $out "  \\addfeature[description=$dID]{domain}{$dStart}{$dStop}\n";
    }
    print $out "\\end{pmbdomains}\n";
  }
  print $out "\\end{document}\n";
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub writePreamble {
  my $fh = shift @_;
  my $data_name = shift @_;
  print $fh "%%%%%%%%%%%%%%%%%%%%\n";
  print $fh "%% pgfmolbio $data_name %%\n";
  print $fh "%%%%%%%%%%%%%%%%%%%%\n";
  print $fh "%% http://www.ctan.org/pkg/pgfmolbio\n";
  print $fh "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
  print $fh "\n"; 
  print $fh "\\documentclass{article}\n";
  print $fh "\\usepackage[domains]{pgfmolbio}\n";
  print $fh "\n";
  print $fh "\\begin{document}\n";

}
