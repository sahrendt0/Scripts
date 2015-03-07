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
use General;
#use Bio::LITE::Taxonomy::NCBI::Gi2taxid qw/new_dict/;
#use Bio::LITE::Taxonomy::NCBI;
#use TokyoCabinet;

## For PFAM stuff
use LWP::UserAgent;
use XML::LibXML;

#####-----Global Variables-----#####
my $input;	         # filename of ids to search
my %gi2tax;
my ($agent,$search);     # objects for http querying
my $out_form = "xml";    # output format is xml for parsing
my ($xml,$xml_parser);   # objects for xml parsing
my $simple_tax;          # filename for a simplified taxonomy list, including NCBI taxIDs
my ($help,$verb);
my ($NCBI_TAX,$NCBI_TAXlite);
my $ncbi = "ncbi";
my $level; # = "order";  #tax level to use
my @levels = qw(kingdom phylum class order family genus species);
my $TAXONLIST = taxonList();
 
my %SPmap = ( "G9NKU3" => 452589,
              "B2ANZ6" => 515849,
              "Q2H7E7" => 306901,
              "G2RAF9" => 578455,
              "G2QCB5" => 573729,
              "B0D621" => 486041,
              "B0DLK5" => 486041,
              "B0CTM6" => 486041);

#my $gi2taxa_idx = '/scratch/gbacc/gi2taxon.tch';
my $gi2taxon = '/rhome/sahrendt/bigdata/Data/Taxonomy/gi_taxid_prot.dmp.gz';

GetOptions ('i|input=s' => \$input,
            'h|help'   => \$help,
            'v|verbose' => \$verb,
            'm|mode=s'  => \$ncbi,
            'level=s'  => \$level);
my $usage = "Usage: pfam2taxa.pl -i input [-m pfam] [--level tax_level]\nGets taxonomy information for a PFAM protein id\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
$agent = LWP::UserAgent->new;
$agent->env_proxy;

if($level)
{
  @levels = ();
  push @levels,$level;
}

my $NC = initNCBI("flatfile");
open(IN,"<",$input) or die "Can't open file $input: $!\n";
while(my $id = <IN>)
{
  chomp $id;
  my ($pfam_id,$gi_id,$tax_id);
  print "$id\t";
  my $localID = (split(/\|/,$id))[0];
  $localID = lc($localID);
#  print $localID,"\n";
  if(exists $TAXONLIST->{$localID})
  {
    $tax_id = $TAXONLIST->{$localID}{TaxID};
    $pfam_id = 0;
    $gi_id = 0;
  }
  elsif ($id =~ /^\w{6}\/\d+-\d+$/)
  {
    my $tmp = (split(/\//,$id))[0];
    $tax_id = $SPmap{$tmp};
    $pfam_id = 0;
    $gi_id = 0;
  }
  else
  {
    $pfam_id = parseId($id) if ($ncbi eq "pfam");  # turn what was in the file into a PFAM readable id
    $gi_id = getGI($id);
    $tax_id = 0;
  }
  if($pfam_id || $gi_id)
  {
    #my $tax_id;
    if($ncbi eq "pfam")
    {
      $tax_id = getXMLInfo($pfam_id,"tax_id");
    }
    else
    {
      $tax_id =  (split(/\t/, `zgrep -P \"\^$gi_id\\t\" $gi2taxon`))[1];
      chomp $tax_id;
    }
  }
#    my $simple_id = simpleId($tax_id);
#    my $simple_id = simpleId(getXMLInfo($pfam_id,"tax_id"); 
  #print "$tax_id\t";
   # print getRank($tax_id,"species"),"\n";
    #print shift (@{getRank($tax_id,"species")}),"\n";
    #print getRank($tax_id,"phylum"),"\n";
  my $tax_hash = getTaxonomybyID($NC,$tax_id);
  printTaxonomy($tax_hash,\@levels,"",$tax_id);
#  my $new_level = $level;
#  my $index = indexOf($new_level,\@levels);
#  while(!exists($tax_hash->{$tax_id}{$new_level}))
#  {
#    $index = indexOf($new_level,\@levels);
#    $index--;
#    #print $index;
#    $new_level = $levels[$index];
#    #print $new_level,"\n";
#  }
#  print $tax_hash->{$tax_id}{$new_level};
#  print "{$new_level}" if ($new_level ne $level);
#  print "\n";
}
close(IN);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getGI {
  my $id = shift @_;
  my @data = split(/\|/,$id);
  if(scalar @data > 2)  # clat ids fail here
  {
    $id = $data[1]; #$NCBI_TAXlite->get_taxonomy_from_gi($data[1]);
  }
  return $id;
}
#
#sub initNCBI {
#  my $tax_dir = "/rhome/sahrendt/bigdata/Data/Taxonomy";
#  my $nodesfile = "$tax_dir/nodes.dmp";
#  my $namesfile = "$tax_dir/names.dmp";
#  my $indexdir = "$tax_dir";
#  my $dictfile = "$tax_dir/gi_taxid_prot.dmp";
#  my $dictbin = "$tax_dir/gi_taxid_prot.bin";
#  $NCBI_TAX = Bio::DB::Taxonomy->new(-source    => 'flatfile',
#                                     -directory => $tax_dir,
#                                     -namesfile => $namesfile,
#                                     -nodesfile => $nodesfile);
#}

sub getRank {
  my $taxonid = shift @_;
  my $rankname = shift @_;
  my $name = "no_phylum\t0";

  if($taxonid != 0)
  {
    my $taxon = $NCBI_TAX->get_taxon(-taxonid => $taxonid);
    while((my $rank = $taxon->rank) ne $rankname)
    {
#       $taxonid = $taxon->parent_id();
      $taxon = $NCBI_TAX->get_taxon(-taxonid => $taxon->parent_id());
      if (!defined($taxon))
      {
        $name = "no_phylum\t0";
        last;
      }
      $name = join("\t",shift(@{$taxon->name("scientific")}),$taxon->id());
    }
  }
  return $name;
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
    #$parsed_id = join("\_",$data[2],$data[3]);
    $parsed_id = join("\_",$data[0],$data[1]);
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
    $return_value = $taxonomy->getAttribute($attribute);
  }
  return $return_value;

}
