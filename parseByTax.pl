#!/usr/bin/perl
# Script: parseByTax.pl
# Description: Trims an "out_table" file in accordance with a specific set of organisms 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.02.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my %out_table;
my @orgs = qw(Amac Bden Cang Clat Gpro Hpol OrpC PirE Rall Spun);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: parseByTax.pl -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
open(my $fh,"<",$input) or die "Can't open $input: $!\n";
my $lc = 0;
my @gene_names;
while (my $line = <$fh>)
{
  chomp $line;
  my @data = split(/\s+/,$line);
  if($lc == 0)
  {
    @gene_names = @data;
  }
  else
  {
    for(my $i=0;$i<scalar(@gene_names); $i++)
    {
      $out_table{$data[0]}{$gene_names[$i]} = $data[$i];
    }
  }
  $lc++;
}
close($fh);

#print Dumper \%out_table;

print join("\t",@gene_names),"\n";
shift @gene_names;
foreach my $org (@orgs)
{
  print $org,"\t";
  foreach my $gene (@gene_names)
  {
    print $out_table{$org}{$gene},"\t";
  }
  print "\n";
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
