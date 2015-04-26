#!/usr/bin/perl
# Script: uniprot2tax.pl
# Description: Takes file with uniprot IDs 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 04.06.2015
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use LWP::UserAgent;
use Bio::DB::SwissProt;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);
my $NCBI = initNCBI("flatfile");

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: uniprot2tax.pl -i input\nTakes file with uniprot IDs and prints uniprot file to be parsed with parseUniprot\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
printUniprotFile($input);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub printUniprotFile {
  my $list = shift @_; # File containg list of UniProt identifiers.
#  print $list,"\n";
  my $base = 'http://www.uniprot.org';
  my $tool = 'batch';

  my $contact = ''; # Please set your email address here to help us debug in case of problems.
  my $agent = LWP::UserAgent->new(agent => "libwww-perl $contact");
  push @{$agent->requests_redirectable}, 'POST';

  my $response = $agent->post("$base/$tool/",
                              [ 'file' => [$list],
                                'format' => 'txt',
                              ],
                              'Content_Type' => 'form-data');

  while (my $wait = $response->header('Retry-After')) 
  {
    print STDERR "Waiting ($wait)...\n";
    sleep $wait;
    $response = $agent->get($response->base);
  }

  $response->is_success ?
    print $response->content :
    die 'Failed, got ' . $response->status_line .
      ' for ' . $response->request->uri . "\n";
}
