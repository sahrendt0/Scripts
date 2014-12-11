#!/usr/bin/perl
# Script: kegg.pl
# Description: Queries the KEGG db to collect taxonomic info
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 12.10.14
################################
# Usage: kegg.pl -o operation -a argument -w output
#    where operation:   info
#			list
#			find
#			get
#			conv
#			link
#################################
# KEGG API: http://www.kegg.jp/kegg/rest/keggapi.html
#################################

use warnings;
use strict;
use SOAP::Lite;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

#my $op = "get"; 
my $arg;
#my $output;
#my $wsite = 'http://rest.kegg.jp';
my $help;
#my $serv = SOAP::Lite -> service($wsdl);

GetOptions ("h|help"        => \$help,
            "a|arg=s"       => \$arg,
);
my $usage = "Usage: kegg.pl -a argument\n";
die $usage if($help);
#$output = $arg;

print kegg2tax($arg);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub kegg2tax {
  my $orgID = shift @_;
  my $taxID;
  `wget -O $orgID http://rest.kegg.jp/get/gn:$orgID`;
  open(IN, "<", $orgID);
  while(my $line = <IN>)
  {
    chomp $line;
    next if ($line !~ /^TAX/);
    $taxID = (split(/[\s+\:]/,$line))[2];
  }
  close(IN);
  #`rm $orgID`;
  return $taxID;
}

