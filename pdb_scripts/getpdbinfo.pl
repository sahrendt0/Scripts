#!/usr/bin/perl -w
# Script: getpdbinfo.pl
# Description: Prints the description (default) and citation lines (optional) for all pdb files in the current directory to pdbinfo.txt
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.13.13
#         v1.0  : citation line might need to be cleaned up
#	        v1.1	: don't grab "chain" files: XXXXA.pdb
#         v1.2  : more output options
##################################
# Optional arguments: -c for "citation"; include if you want a citation line
#                     -s for "species"; include if you want to see the source organism
#                     -v for "verbose"; print to screen and don't update README
##################################
# Usage: [-c] [-s] [-v] getpdbinfo.pl
##################################

use strict;
use warnings;
use Getopt::Std;

my $outfile = "README";
my $dir = ".";

# Handle command-line options
my %opts;
getopts('csv', \%opts);

## Grab all of the pdb files in the current directory
opendir(DIR,$dir) || die "Can't open dir $dir.\n";
my @pdbs = grep { /^\w{4}\.pdb$/} readdir(DIR);
closedir(DIR);

## Print the relevant lines about each ID
if(!(exists $opts{'v'}))
{
  open(OUT, ">$outfile");
  foreach my $pdb (@pdbs)
  {   
    print OUT substr($pdb,0,4),"\t";
    print OUT &getDesc($pdb);
    print OUT "\n";
    if (exists $opts{'c'})
    {
      print OUT &getCite($pdb);
      print OUT "\n";
    }
    if (exists $opts{'s'})
    {
      print OUT &getOrg($pdb);
      print OUT "\n";
    }
  }
  close(OUT);
}
else
{
  foreach my $pdb (@pdbs)
  {
    print substr($pdb,0,4),"\t";
    print &getDesc($pdb);
    print "\n";
    if (exists $opts{'c'})
    {
      print &getCite($pdb);
      print "\n";
    }
    if (exists $opts{'s'})
    {
      print &getOrg($pdb);
      print "\n";
    }
  }

}

## Get the description line
sub getDesc()
{
  my $f = shift;
  #print $f;
  open(P,"<$f");
  my @pdb = <P>;
  close(P);
  my @titles = grep {/TITLE/} @pdb;

  my $desc = "";
  foreach my $title (@titles)
  {
    #print "<$desc>";
    $title =~ s/\r//g;
    chomp($title);
    #print $title;
    $desc = join("",$desc,$title);
    }
  $desc =~ s/\s+/ /g;
  $desc =~ s/\s*TITLE\s+\d*//g;
  #print "\nDesc: $desc\n";
  return $desc;
}

## Get the source organism line
# SOURCE   2 ORGANISM_SCIENTIFIC: NATRONOMONAS PHARAONIS;
sub getOrg()
{
  my $f = shift;
  open(P,"<$f");
  my @pdb = <P>;
  close(P);
  my @orgs = grep {/ORGANISM_SCIENTIFIC/} @pdb;

  my $org = (split(/[:|;]/,$orgs[0]))[1];
  $org =~ s/^\s+//;
  $org =~ s/\s+$//;
  $org = join(""," ",$org);
  return $org;
}

## Get the citation line
sub getCite()
{
  my $cite = "";
  my $f = shift;
  open(P,"<$f");
  my @pdb = <P>;
  close(P);
  my @auths = grep {/^AUTHOR/} @pdb;
  my @jrns = grep {/^JRNL/} @pdb;
  my $a = " ";
  foreach my $athr (@auths)
  {
    chomp($athr);
    $athr =~ s/\s*AUTHOR\s+\d*//;
    $athr =~ s/\+//g;
    $a = join("",$a,$athr);
  }
  my $j = " ";
  foreach my $jrn (@jrns)
  {
    if(($jrn =~ m/ REF /) || ($jrn =~ m/ DOI /))
    {
        chomp($jrn);
        $jrn =~ s/\s*JRNL\s+\d*//;
        $jrn =~ s/\s+/ /g;
        $j = join("",$j, $jrn);
    }
  }
  #$a =~ s/\s+//g;
  $j =~ s/REF/JRNL:/;
  $j =~ s/DOI/DOI:/;
  $cite = join("\n",$a,$j);
  #$cite =~ s/\s+/ /g;
  return $cite;
}
