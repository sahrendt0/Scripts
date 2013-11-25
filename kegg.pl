#!/usr/bin/perl
# Script: kegg.pl
# Description: Queries the KEGG db to collect genes in a given pathway
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 9.18.13
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

my $op; 
my $arg;
my $output;
my $wsite = 'http://rest.kegg.jp';
my $help=0;
#my $serv = SOAP::Lite -> service($wsdl);

GetOptions ("h|help+"       => \$help,
            "o|operation=s" => \$op,
            "a|arg=s"       => \$arg,
            "w|write=s"     => \$output);

if($help)
{
  print "Usage: kegg.pl -o operation -a argument [-w output]\n";
  print "       where operation:   info\n";
  print "                          list\n";
  print "                          find\n";
  print "                          get\n";
  print "                          conv\n";
  print "                          link\n";
  exit;
}

if(!($output))
{
  $output = $arg;
}

print `wget -O $output $wsite/$op/$arg`;

__END__
## Get all KOs using the pathway provided 
#   Loop through KOs
my $results = $serv->get_kos_by_pathway("path:map$path_id");
foreach my $res (@{$results})
{
  my $ko_id = (split(/:/,$res))[1];
  print $ko_id,"\n";
}
__END__
  my $seqIO = Bio::SeqIO->new(-file => ">$ko_id.faa",
                              -format => 'fasta');

  foreach my $gene (@{$serv->get_genes_by_ko($res,'all')}) # get all of the genes associated with that KO
  {
    my $seq = $serv->bget("-f -n a $gene->{entry_id}"); # retrieve fasta format; is just one long string starting with ">" and some newlines

    ## Can just use the above $seq if you want...just printing it out would be FASTA format
    #   The following lines process the above into a Bio::Seq object
    my $seq_str = "";
    my ($header,@sequence) = split(/\n/,$seq);
    $header =~ s/>//;
    foreach my $seq_frag (@sequence)
    {
      $seq_str = join("",$seq_str,$seq_frag);
    }
    my $seq_obj = Bio::Seq->new(-id => $header,
                                -seq => $seq_str);
    $seqIO->write_seq($seq_obj);
  }
}


__END__
$genes = SOAP::Data->type(array => ["eco:b1002", "eco:b2388"]);

$result = $serv -> mark_pathway_by_objects("path:eco00010", $genes);

print $result;	# URL of the generated image

__END__
$wsdl = 'http://soap.genome.jp/KEGG.wsdl';

$results = SOAP::Lite
             -> service($wsdl)
             -> list_pathways("eco");

foreach $path (@{$results}) {
  print "$path->{entry_id}\t$path->{definition}\n";
}


__END__
$wsdl = 'http://soap.genome.jp/KEGG.wsdl';

$serv = SOAP::Lite->service($wsdl);

$offset = 1;
$limit = 5;

$top5 = $serv->get_best_neighbors_by_gene('eco:b0002', $offset, $limit);

foreach $hit (@{$top5}) {
  print "$hit->{genes_id1}\t$hit->{genes_id2}\t$hit->{sw_score}\n";
}
