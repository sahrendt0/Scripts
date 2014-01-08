#!/usr/bin/perl
# Script: fasta2go.pl
# Description: Joins geneIDs to GO terms using previously established DBs 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 01.07.2014
##################################
# Essentially
##################################
# GO map file format:
# proteinId	gotermId	goName	gotermType	goAcc
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use Data::Dumper;

#####-----Global Variables-----#####
my $infile; # Fasta file
my $GOmap;
my $GOdb = "/rhome/sahrendt/bigdata/Genomes/Functional/GO";
my $PFdb = "/rhome/sahrendt/bigdata/Genomes/Functional/PFAM";
my $pfam2go = "/rhome/sahrendt/Data/GO/pfam2go";
my %PFGOMAP; # mapping of pfam to GO
my %GOhash;
my $org;
my ($help,$verb,$all);
my $dbfile; # for output
my @infiles;
GetOptions ('i|input=s' => \$infile,
            'h|help'   => \$help,
            'v|verbose' => \$verb,
            'a|all'     => \$all);
my $usage = "Usage: fasta2go.pl -a|-i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$infile && !$all);
  
#####-----Main-----#####
if($all)
{
  opendir(DIR,".");
  @infiles = grep {/\.fasta$/} readdir(DIR);
  closedir(DIR);
}
else
{
  push(@infiles,$infile);
}

foreach my $input (@infiles)
{
  my $numGOIDs = 0;
  ## If org uses GO Map
  $org = (split(/\./,$input))[0];
  $GOmap = "$GOdb/$org\_GO.tab";
  #print $GOmap,"\n";

  if(open(GO,"<$GOmap")) # or die "Can't open $GOmap: $!\n";
  {
    $dbfile = $GOmap;
    while (my $line = <GO>)
    {
      chomp $line;
      next if($line =~ m/^#/);
      my ($proteinId,$gotermId,$goName,$gotermType,$goAcc) = split(/\t/,$line);
      $GOhash{$proteinId}{$goAcc}{'GOName'} = $goName;
      $GOhash{$proteinId}{$goAcc}{'GOTermType'} = $gotermType;
      $numGOIDs++;
    }
    close(GO);
  }
  else
  {
    warn "No GO file for $org!\nChecking PFAM...\n";
    makeHash($pfam2go);
    my $pfile = "$PFdb/$org\_pfam_to_genes.txt";
    $dbfile = $pfile;
    if(open(PFAM,"<$pfile")) # or die "Can't open $pfile: $!\n";
    {
      #print Dumper \%PFGOMAP;
      while(my $line = <PFAM>)
      {
        next if($line =~ /^PROTEIN_NAME/);
        chomp $line;
        my @data = split(/\t/,$line);
        my $proteinId = $data[1];
        my $PFid = (split(/\./,$data[3]))[0];
        #print "$proteinId $PFid\n";
        if(exists $PFGOMAP{$PFid})
        {
          $numGOIDs++;
          my @GOAcc = @{$PFGOMAP{$PFid}{"GO"}{"ids"}};
          #print $GOAcc[0],"\n";
          my @GONames = @{$PFGOMAP{$PFid}{"GO"}{"desc"}};
          my @GOTTypes = @{$PFGOMAP{$PFid}{"GO"}{"type"}};
          for(my $i = 0; $i<scalar(@GOAcc); $i++)
          {
            $GOhash{$proteinId}{$GOAcc[$i]}{"GOName"} = $GONames[$i];
            $GOhash{$proteinId}{$GOAcc[$i]}{"GOTermType"} = $GOTTypes[$i];
          }
        }
        else
        {
          warn "Error in file $dbfile: PFAMid $PFid has no GO mapping\n";
        }
      }
    }
    else
    {
      print "No GO or PFAM file for $org!\n";
    }
    close(PFAM);
  }
  if($numGOIDs)
  {
    ## Output in format:
    #  transcriptID<tab>GO_ID1,GO_ID2,GO_ID3,...
    open (OUT,">$input.gene2go");
    print OUT "# Used $dbfile to generate list\n";
    print OUT "# $numGOIDs GO IDs in database\n";
    print OUT "# TranscriptID	List of GO IDs\n";
  
    # Read the specified fasta file and use display_ids for keys  
    my $fasta_in = Bio::SeqIO->new(-file => $input,
                                   -format => "fasta");
    while(my $seq_obj = $fasta_in->next_seq)
    {
      my $t_id = $seq_obj->display_id;
      print OUT "$t_id\t";
      print OUT join(",",sort keys %{$GOhash{$t_id}}),"\n";
    }
    close(OUT);
  }
  else
  {
    print "Error with $org: No GO IDs exist\n";
    print "If PFAM annotation file exists, then none of the PFAM IDs could be mapped to GO IDs\n";
    print "Not writing $input.gene2go\n";
  }
}

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub makeHash {
  my $file = shift;
  open(P2G, '<', $file) or die "Can't open $file: $!\n";
  while(my $line = <P2G>)
  {
    chomp $line;
    next if ($line =~ m/^!/);
    #print $line,"\n";
    #my ($PID,$Pdesc,$GOdesc,$GOID);
    my ($pf,$go) = split(/>/,$line);
    #print join("--",$pf,$go),"\n";
    my ($tmp,$PID,$Pdesc,@tmp2) = split(/[:| ]/,$pf);
    #print $PID,"--",$Pdesc,"\n";
    my ($GOdesc,$GOID,$GOtype) = split(/\s*;\s*/,$go);
    $GOdesc =~ s/^\s//;
    #print "  $GOID--$GOdesc\n";
    $PFGOMAP{$PID}{"desc"} = $Pdesc;
    push (@{$PFGOMAP{$PID}{"GO"}{"ids"}}, $GOID);
    push (@{$PFGOMAP{$PID}{"GO"}{"desc"}},$GOdesc);
    push (@{$PFGOMAP{$PID}{"GO"}{"type"}},$GOtype);
  }
  close(P2G);
}
