#!/usr/bin/perl
# Script: pfam2taxa.pl
# Description: Gets taxonomy information for a PFAM protein id 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.30.2014
##################################
# http://pfam.xfam.org/help#tabview=tab10
#######################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;

## For PFAM stuff
use LWP::UserAgent;
use XML::LibXML;

#####-----Global Variables-----#####
my $input;	         # filename of ids to search
my ($agent,$search);     # objects for http querying
my $out_form = "xml";    # output format is xml for parsing
my ($xml,$xml_parser);   # objects for xml parsing
my $simple_tax;          # filename for a simplified taxonomy list, including NCBI taxIDs
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: pfam2taxa.pl -i input\nGets taxonomy information for a PFAM protein id\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
$agent = LWP::UserAgent->new;
$agent->env_proxy;

open(IN,"<",$input) or die "Can't open file $input: $!\n";
while(my $id = <IN>)
{
  chomp $id;
  print "$id\t";
  my $pfam_id = parseId($id);  # turn what was in the file into a PFAM readable id
  if($pfam_id)
  {
    my $tax_id = getXMLInfo($pfam_id,"tax_id");
#    my $simple_id = simpleId($tax_id);
#    my $simple_id = simpleId(getXMLInfo($pfam_id,"tax_id"); 
    print "$tax_id\n";
#    print "$simple_id\n";
  }
  else
  {
    print "CF\n";
  }
  
}
close(IN);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getRank {
  my $taxonid = shift @_;
  my $rank = shift @_;
  ## 1) set up TAx DB: local
  ## 2) my $taxon = $db->get_taxon(-taxonid => $taxonid);
  ## 3) my $rank = $curr_node->rank;
}

#######
## Subroutine: simpleId
#       Input: an NCBI taxonomy id
#     Returns: a simple string denoting relative placement
#               like something found in the taxonlist file
##############
sub simpleId {
  my $id = shift @_;
  my $simple_id = "";
  return $simple_id;
}

#######
## Subroutine: parseId
#       Input: works on a specific coded file, specific to this analysis
#     Returns: the Ids which correspond to PFAM formatted strings
##############
sub parseId {
  my $id = shift @_;
  my $parsed_id = ""; 
  my @data = split(/[\_\/]/,$id);
  if(scalar @data > 1)  # clat ids will fail here
  {
    $parsed_id = join("\_",$data[2],$data[3]);
  }
  return $parsed_id;
}

###########
## Subroutine: getXMLInfo
#       Input: an id and an attribute value
#               currently only works with PFAM protein Ids
#                and searches to find NCBI tax ids for them
#     Returns: the NCBI taxid for each string
################
sub getXMLInfo {
  my $id = shift @_;
  my $attribute = shift @_;
  my $return_value = "";

  my $search = $agent->get("http://pfam.xfam.org/protein?id=$id&output=xml"); # search for something with id
  die "Failed to retrieve XML: ".$search->status_line,"\n" unless $search->is_success;

  my $xml = $search->content;
  my $xml_parser = XML::LibXML->new();
  my $dom = $xml_parser->parse_string( $xml );

  my $root = $dom->documentElement();
  my ($entry) = $root->getChildrenByTagName("entry");
  
  if($attribute eq "tax_id")
  {
    my ($taxonomy) = $entry->getChildrenByTagName("taxonomy");
    print $taxonomy->content,"\n";
    $return_value = $taxonomy->getAttribute($attribute);
  }
  return $return_value;

}
