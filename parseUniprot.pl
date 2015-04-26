#!/usr/bin/perl
# Script: parseUniprot.pl
# Description:  
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.06.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use Data::Dumper;

#####-----Global Variables-----#####
my $input;
my $accnos;
my ($help,$verb);
my @levels = @STD_TAX;
my $level; # tax level (provided by user)

GetOptions ('i|input=s' => \$input,
            'a|accnos=s' => \$accnos,
            'h|help'   => \$help,
            'v|verbose' => \$verb,
            'level=s'   => \$level);
my $usage = "Usage: parseUniprot.pl -i input\n\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
if($level)
{
  @levels=();
  push @levels,$level;
}

my $NC = initNCBI("flatfile");
my $uniprotData = parseUniprot($input);
open(my $ac,"<",$accnos);
while(my $AC = <$ac>)
{
  chomp $AC;
  my $ID = upACtoID($AC);
  #print $ID,"\n";
  if(exists($uniprotData->{$ID}))
  {
    my $taxID = $uniprotData->{$ID}{"TaxID"};
    my $tax_hash = getTaxonomybyID($NC,$taxID);
    print "$AC\t";
    printTaxonomy($tax_hash,\@levels,"",$taxID);
  }
}
#print Dumper $uniprotData;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub upACtoID {
  my $AC = shift @_;
  my $ID = "";
  my $base = 'http://www.uniprot.org';
  my $tool = 'mapping';
  my $params = {
    from => 'ACC',
    to => 'ID',
    format => 'tab',
    query => $AC #P13368 P20806 Q9UM73 P97793 Q17192'
  };

  my $contact = 'sahre001@ucr.edu'; # Please set your email address here to help us debug in case of problems.
  my $agent = LWP::UserAgent->new(agent => "libwww-perl $contact");
  push @{$agent->requests_redirectable}, 'POST';

  my $response = $agent->post("$base/$tool/", $params);

  while (my $wait = $response->header('Retry-After')) {
    print STDERR "Waiting ($wait)...\n";
    sleep $wait;
    $response = $agent->get($response->base);
  }

  if($response->is_success)
  {
    my @ids = split(/\n/,$response->content);
    shift @ids;
    $ID = (split(/\s+/,$ids[0]))[1];
  } 
  return $ID;
}

sub parseUniprot {
  my $file = shift @_;
  my %hash;
  open(my $fh, "<",$file) or die "Can't open $file: $!\n";
  my $id = "";
  while (my $line = <$fh>)
  {
    chomp $line;
    if($line =~ /^ID/)
    {
      my @data = split(/\s+/,$line); # mol = AA 
      $id = $data[1];
    }
    if($line =~ /^AC/)
    {
      my @ac = split(/\s+/,$line);
      shift @ac;
      @ac = grep(s/;$//g,@ac);
      $hash{$id}{"AC"} = \@ac;
    }
    if($line =~ /^OX/)
    {
      my $tax = (split(/\s+/,$line))[1];
      $hash{$id}{"TaxID"} = (split(/=/,$tax))[1];
      $hash{$id}{"TaxID"} =~ s/;$//;
    }
  }
  close $fh;
  return \%hash;
}
