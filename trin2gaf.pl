#!/usr/bin/perl
# Script: trin2gaf.pl
# Description: Maps trinotate file to GO association file for GOSlim 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 07.25.2014
##################################
#
# Imp?	Col	Content		Required	Ex
# [x]	1	DB		y		UniProtKB
# [x]	2	DB Obj ID	y		P12345
# [x]	3	DB Obj symbol	y		PHO3
# [x]	4	Qualifier	n		NOT
# [x]	5	GO ID		y		GO:0003993
# [x]	6	DB:Reference	y		PMID:267609
# [x]	7	Evidence code	y		IEA
# [x]	8	With (or) from	n		GO:0000346
# [x]	9	Aspect		y		F(unction)
# [x]	10	DB Object Name	n		Toll-like receptor 4	
# [x]	11	DB object Syn	n		hToll|Tollbooth
# [x]	12	DB Object type	y		protein
# [x]	13	Taxon		y		taxon:9606
# [x]	14	Date		y		20090118 (date of annotation)
# [x]	15	Assigned by	y		Trinotate
# [x]	16	Annot ext	n
# [x]	17	GeneProd 	n
###################################
# Tasks
#  [x] get taxID from species (col 13)
#  [x] get PMID reference from best blast hit (col 6)
#  [x] get namespace of GO ID (col 9): "C", "P", "F"
#  [x] use col 1 for col 15
######################################
# UniProtKB mapping file:
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz
# 2) idmapping_selected.tab
# We also provide this tab-delimited table which includes
# the following mappings delimited by tab:
#
# 1. UniProtKB-AC
# 2. UniProtKB-ID
# 3. GeneID (EntrezGene)
# 4. RefSeq
# 5. GI
# 6. PDB
# 7. GO
# 8. UniRef100
# 9. UniRef90
# 10. UniRef50
# 11. UniParc
# 12. PIR
# 13. NCBI-taxon
# 14. MIM
# 15. UniGene
# 16. PubMed
# 17. EMBL
# 18. EMBL-CDS
# 19. Ensembl
# 20. Ensembl_TRS
# 21. Ensembl_PRO
# 22. Additional PubMed
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use Bio::DB::EUtilities;
use Data::Dumper;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $input;
my %lineData;
my $ll_file = "/rhome/sahrendt/bigdata/Data/Genbank/GbAccList.0720.2014.gz";
my $IDMAPPING = "/rhome/sahrendt/bigdata/Data/UniProt/idmapping_selected.tab.gz";
my $TRIN_DATE = "20140616";
my ($help,$verb);

GetOptions ('i|input=s' => \$input,
            'l|livelist=s' => \$ll_file,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: trin2gaf.pl -i input -l livelist\nMaps trinotate file to GO association file for GOSlim\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
#%livelist = hashLiveList($ll_file);
#print Dumper \%livelist;

open(my $fh,"<",$input) or die "Can't open $input: $!\n";
while (my $line = <$fh>)
{
  next if($line =~ /^#/);
  chomp $line;
  my($gene_id, $transcript_id, $top_blX, $RNAMMER, $prot_id, $prot_coords, $top_blP, $PFAM, $SigP, $TMHMM, $eggnog, $GO) = split(/\t/,$line);
  if($GO ne ".")
  {
    my @go_terms = split(/\`/,$GO);
    foreach my $goID (@go_terms)
    {   
      my($ID,$type,$desc) = split(/\^/,$goID);
      
      my @gaf_line = qw(. . . . . . . . . . . . . . . . .);

      # set up DB fields
      $gaf_line[0] = "UniProtKB";
      $gaf_line[14] = $gaf_line[0];
    #  my $DB_obj = split(/\^/,$top_blX);
      my $blast_hit = $top_blX;
      $blast_hit = $top_blP if($blast_hit eq ".");
      my($db,$db_obj_id,$db_obj_sym) = split(/\|/, (split(/\^/,$blast_hit))[0]);
      $gaf_line[1] = $db_obj_id;
#      print getGI($db_obj_id,$ll_file),"\n";
      $gaf_line[2] = $db_obj_sym; 
      $gaf_line[4] = $ID;
      $gaf_line[6] = "IEA";
      $gaf_line[8] = uc((split(//, (split(/\_/,$type))[1] ))[0]);
      $gaf_line[11] = "protein";
      $gaf_line[13] = $TRIN_DATE;
      $gaf_line[14] = "Trinotate";
      if(!exists $lineData{$db_obj_id})
      {
        getDataFromId($db_obj_id);
      }
      $gaf_line[12] = join(":","taxon",$lineData{$db_obj_id}{"Taxon"});
      $gaf_line[5] = join(":","PMID",$lineData{$db_obj_id}{"PubMed"});

#      $gaf_line[12] = join(":","taxon",getTaxID(getGI($db_obj_id,$ll_file)));
      print "@gaf_line\n";
    }
  }
}
close($fh);

#my %hash_data = getDataFromId("Q8TGM6");
#print $hash_data{"Taxon"},"\n";
#print $hash_data{"PubMed"},"\n";
#print join(":","PMID",(split(/; /,$hash_data{"PubMed"}))[0]),"\n";

#my $GI = getTaxID("Q8TGM6");

#print $GI,"\n";

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getDataFromId{
  my $spID = shift @_;
#  print "<$spID>\n";
  my %result;
  open(my $fh,"gunzip -c $IDMAPPING |") or die "Can't gunzip $IDMAPPING: $!\n";
# my $c=0;
  while(my $line = <$fh>)
  {
#    print "line $c\n";
#    $c++;
    chomp $line;
    my @data = split(/\t/,$line);
    if($spID eq $data[0])
    {
      $lineData{$spID}{"Taxon"} = $data[12];
      $lineData{$spID}{"PubMed"} = (split(/; /,$data[15]))[0];
      last;
    }
  }
  close $fh;
}
__END__
sub getTaxID{
  my $input = shift @_;
  my $taxID = "0";
  my $base = 'http://www.uniprot.org';
  my $tool = 'mapping';

  my $params = {
    from => 'ACC',
    to => 'P_REFSEQ_AC',
    format => 'tab',
    query => $input
  };

  my $contact = ''; # Please set your email address here to help us debug in case of problems.
  my $agent = LWP::UserAgent->new(agent => "libwww-perl $contact");
  push @{$agent->requests_redirectable}, 'POST';

  my $response = $agent->post("$base/$tool/", $params);

  while (my $wait = $response->header('Retry-After')) {
    print STDERR "Waiting ($wait)...\n";
    sleep $wait;
    $response = $agent->get($response->base);
  }

  $response->is_success ?
    my $result = $response->content :
    die 'Failed, got ' . $response->status_line .
      ' for ' . $response->request->uri . "\n";

  my @dat = split(/\s/,$result);
  my $rfID = pop @dat;
  print $rfID,"\n";


  open(my $gh,"<","gene2refseq") or die "Can't open gene2refseq\n";
  my $c = 0;
  while (my $line = <$gh>)
  {
    next if ($line =~ /^#/);
    chomp $line;
    my @data = split(/\t/,$line);
    $c++;
    if ($rfID eq $data[5])
    { 
      $taxID = $data[0];
      warn "$c items searched";
      last;
    }
  }
  close($gh);  


  return $taxID;
}

sub getGI {
  my %data;
  my $sp = shift @_;
  my $list = shift @_;
  my $res = "Not found";
  open(my $fh,"gunzip -c $list |") or die "Can't gunzip $list: $!\n";
  while(my $line = <$fh>)
  {
    chomp $line;
    my($id,$ver,$GI) = split(/,/,$line);
    if($id eq $sp)
    {
      $res = $GI;
      last;
    }
  }
  close($fh);
  return $res;
}
