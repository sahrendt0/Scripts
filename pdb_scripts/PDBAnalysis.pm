package PDBAnalysis;
# Name: PDBAnalysis.pm
# Description: Subroutines for processing PDB files (uses ParsePDB)
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.7.13
#######################
# Functionality includes:
#  [x] parse HELIX into array	: parseHelix(str helix_line)
#  [x] print HELIX lines	: printHelics(obj PDB)
#  [x] get HELIX lines		: getHelices(obj PDB)
#  [x] extract fragment of PDB	: extractFrag(obj PDB, int start, int end)
#  [x] get PDBs from PDB	: getPDB(str id)
#  [x] write a specific chain	: writeChain(str id, str chain)
#  [ ] parse ATOM into array	: 
#  [x] get experiment type	: getExp(obj PDB)
########################
use strict;
use warnings;
use ParsePDB;
use LWP::Simple;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(parseHelix printHelics getHelices extractFrag writeChain getExp); # export always

#####
# getPDB takes an input ID
sub getPDB
{
  my $pdbid = lc(shift @_);
  chomp($pdbid);
  if($pdbid !~ m/^\w{4}$/)
  {
    die "$pdbid not a valid PDB ID code\n";
  }
  my $url = "http://www.rcsb.org/pdb/files/$pdbid.pdb";
  print `wget -q $url`;
  my $updbid = uc($pdbid);
  print `mv $pdbid.pdb $updbid.pdb`;
}

#####
# writeChain takes a pdbID and a chain description
#   uses ParsePDB to get and write the provided Chain
#   does not return anything
sub writeChain
{
  my $id = shift @_;
  my $chain = shift @_;
  my $filename = "$id.pdb";
  my $PDB = ParsePDB->new(
    FileName => $filename,
    NoHETATM => 1,  # filter HETATM lines
    NoANISIG => 1   # filter SIGATM, SIGUIJ, ANISOU lines
  );
  $PDB->Parse;
  my $chainfile = "$id\_$chain.pdb";
  open(OUT,">$chainfile");
  print OUT $PDB->Get(Model => 0,ChainLabel => "$chain"),"\n";
  close(OUT);
  print "\n";
}


###
# Sub: parseAtom
#  Expects a PDB ATOM line
#  Parses components into array bsed on PDB file format
#  Returns array
######
sub parseAtom
{
  ##
  # PDB file format is based on explicit spacing, not just tab-delimited
  #   Format documentation can be found: http://www.wwpdb.org/documentation/format33/v3.3.html
  #######
}

###
# Sub: parseHelix
#  Expects a PDB HELIX line
#  Parses components into array based on PDB file format
#  Returns array
######
sub parseHelix
{
  my $line = shift;
  my @data = split(//,$line);
  my @parsedData;

  ##
  # PDB file format is based on explicit spacing, not just tab-delimited
  #   Format documentation can be found: http://www.wwpdb.org/documentation/format33/v3.3.html
  #######
  push(@parsedData,join("",@data[0..5]));    # HELIX
  push(@parsedData,join("",@data[7..9]));    # serNum
  push(@parsedData,join("",@data[11..13]));  # helixID
  push(@parsedData,join("",@data[15..17]));  # initResName
  push(@parsedData,$data[19]);               # initChainID
  push(@parsedData,join("",@data[21..24]));  # initSeqNum
  push(@parsedData,$data[25]);               # initICode
  push(@parsedData,join("",@data[27..29]));  # endResName
  push(@parsedData,$data[31]);               # endChainID
  push(@parsedData,join("",@data[33..36]));  # endSeqNum
  push(@parsedData,$data[37]);               # endICode
  push(@parsedData,join("",@data[38..39]));  # helixClass
  push(@parsedData,join("",@data[40..69]));  # comment
  push(@parsedData,join("",@data[71..75]));  # length

  return @parsedData;
}

###
# Sub: extractFrag
#  Expects PDB object and start/stop residue positions
#  Returns array w/ full ATOM data lines from PDB file between two residue positions
#####
sub extractFrag
{
  my ($PDB,$start,$stop) = @_;
  my @return;
  #print $start,$stop,"\n";
  for(my $r=$start;$r<=$stop;$r++)
  {
    push (@return,$PDB->Get (ResidueNumber => $r, ChainLabel => 'A'));
  }
  return @return;
}

### 
# Sub: getHelices
#  Expects PDB object
#  Returns array of all lines in section starting w/ HELIX
#####
sub getHelices
{
  my $PDB = shift @_; 
  my @Section = $PDB->GetSection ("HELIX");
  return @Section;
}

### 
# Sub: getExp
#  Expects PDB object
#  Returns EXPDATA line
#####
sub getExp
{
  my $PDB = shift @_;
  my @Section = $PDB->GetSection ("EXPDTA");
  return @Section;
}

###
# Sub: printHelices
#  Expects PDB object
#  Prints out all lines in section starting w/ HELIX
#####
sub printHelices
{
  my $PDB = shift @_;
  my @Section = $PDB->GetSection ("HELIX");
  print @Section;
}

1;
