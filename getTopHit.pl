#!/usr/bin/perl
# Script: getTopHit.pl
# Description: Gets the top hit from an m8 formatted blast results file 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.17.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::SearchIO;

#####-----Global Variables-----#####
my $infile;
my @infiles;
my ($help,$verb);
my $all;
my ($format,$ext);
GetOptions ('i|input=s' => \$infile,
            'h|help'   => \$help,
            'v|verbose' => \$verb,
            'a|all'     => \$all,
            'f|format=s' => \$format);
my $usage = "Usage: getTopHit.pl -i input -f format\nOutput to STDOUT\n";
die $usage if $help;
die "No input.\n$usage" if (!$infile) && (!$all);
die "No format.\n$usage" if (!$format);
#####-----Main-----#####
push @infiles,$infile;

foreach my $input (@infiles)
{
  my $in = Bio::SearchIO->new(-file => $input,
                              -format => $format);
  while(my $result = $in->next_result)
  {
    printBLASTm8($result);
  }
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
#####
## Subroutine: printBLASTm8
#   Input: Bio::Search::Result::ResultI compliant object
#   Output: an m8 formatted blast line, printed to STDOUT
############
###
### BLAST:	query  		    subject    %id		    alignment_len	  mismatches  gap_open  query_start  query_end  subject_start  subject_end  E_val  bit_score
###
### BioPerl:	result->query_name  hit->name  hsp->frac_identical  hsp->length('total')  	
sub printBLASTm8
{
  my $result = shift @_;#= $in->next_result;
  my $hit = $result->next_hit;
  my $hsp = $hit->next_hsp;
  ## Result stuff
#  print $result->algorithm," algorithm string\n";
#  print $result->algorithm_version," algorithm version\n";
  print $result->query_name,"\t";#," query name\n";
#  print $result->query_accession," query accession\n";
#  print $result->query_length," query length\n";
#  print $result->query_description," query description\n";
#  print $result->database_name," database name\n";
#  print $result->database_letters," number of residues in database\n";
#  print $result->database_entries," number of database entries\n";
#  print $result->available_statistics," statistics used\n";
#  print $result->available_parameters," parameters used\n";
#  print $result->num_hits," number of hits\n";
#  print $result->hits," List of all Bio::Search::Hit::GenericHit object(s) for this Result\n";


  ## Hits
  print $hit->name,"\t";#," hit name\n";
  printf("%.2f\t", $hsp->percent_identity);
  print $hsp->length('total'),"\t";#," length of HSP (including gaps)\n";
  print $hsp->length('total') - $hsp->num_identical,"\t";
  print $hsp->gaps,"\t";
  print $hsp->start('query'),"\t";
  print $hsp->end('query'),"\t";
  print $hsp->start('hit'),"\t";
  print $hsp->end('hit'),"\t";
  print $hit->significance,"\t";#," hit significance\n";
  print $hsp->bits,"\t";#," score in bits\n";
#  print $hit->length," Length of the Hit sequence\n";
#  print $hit->accession," accession number\n";
#  print $hit->description," hit description\n";
#  print $hit->algorithm," algorithm\n";
#  print $hit->raw_score," hit raw score\n";

#  print $hit->bits," hit bits\n";
#  print $hit->hsps," List of all Bio::Search::HSP::GenericHSP object(s) for this Hit\n";
#  print $hit->num_hsps," number of HSPs in hit\n";
#  print $hit->locus," locus name\n";
#  print $hit->accession_number," accession number\n";
  

  ## HSPs
#  print $hsp->algorithm," algorithm\n";
#  print $hsp->evalue," e-value\n";
#  print $hsp->expect," alias for evalue()\n";

#  print $hsp->frac_conserved," fraction conserved (conservative and identical replacements aka \"fraction similar\")\n";

#  print $hsp->query_string," query string from alignment\n";
#  print $hsp->hit_string," hit string from alignment\n";
#  print $hsp->homology_string," string from alignment\n";

#  print $hsp->length('hit')," length of hit participating in alignment minus gaps\n";
#  print $hsp->length('query')," length of query participating in alignment minus gaps\n";
#  print $hsp->hsp_length," Length of the HSP (including gaps) alias for length('total')\n";
#  print $hsp->frame," \$hsp->query->frame,\$hsp->hit->frame\n";
#  print $hsp->num_conserved," number of conserved (conservative replacements, aka \"similar\") residues\n";
#  print $hsp->num_identical," number of identical residues\n";
#  print $hsp->rank," rank of HSP\n";
#  print $hsp->seq_inds('query','identical')," identical positions as array\n";
#  print $hsp->seq_inds('query','conserved-not-identical')," conserved, but not identical positions as array\n";
#  print $hsp->seq_inds('query','conserved')," conserved or identical positions as array\n";
#  print $hsp->seq_inds('hit','identical')," identical positions as array\n";
#  print $hsp->seq_inds('hit','conserved-not-identical')," conserved not identical positions as array\n";
#  print $hsp->seq_inds('hit','conserved',1)," conserved or identical positions as array, with runs of consecutive numbers compressed\n";
#  print $hsp->score," score\n";

#  print $hsp->range('query')," start and end as array\n";
#  print $hsp->range('hit')," start and end as array\n";

#  print $hsp->strand('hit')," strand of the hit\n";
#  print $hsp->strand('query')," strand of the query\n";

#  print $hsp->matches('hit')," number of identical and conserved as array\n";
#  print $hsp->matches('query')," number of identical and conserved as array\n";
#  print $hsp->get_aln," Bio::SimpleAlign object\n";
  print "\n";
}
