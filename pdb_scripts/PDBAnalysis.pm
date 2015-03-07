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
#  [x] parse ATOM into array	: parseAtom(str atom_line)
#  [x] get experiment type	: getExp(obj PDB)
#  [x] get specific atom	: getAtom(int atom_num)
########################
# PDB file format is based on explicit spacing, not just tab-delimited
#   Format documentation: http://www.wwpdb.org/documentation/format33/v3.3.html
#############################################################################################################
use strict;
use warnings;
use ParsePDB;
use LWP::Simple;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(getAtom 
                 parseAtom 
                 parseHelix 
                 printHelics 
                 getHelices 
                 extractFrag 
                 writeChain 
                 getExp
                 getSeqFromFile
); # export always

##################
## subroutine: getSeqFromFile
#       Input: filename for pdb file
#     Returns: Bio::Seq object 
#############
sub getSeqFromFile
{
  my $filename = shift @_;
  my $PDB = ParsePDB->new(FileName => $filename);
  my @fasta = $PDB->GetFASTA (Model => 0);
  chomp @fasta;
  #print join("\n",@fasta),"\n";
  my $header = shift @fasta;
  $header =~ s/^>//;  # The GetFASTA method adds the > symbol
                      # But so does bio::Seq, so remove it here
  my $sequence = join("",@fasta);
  #print $header,"\n",$sequence,"\n";
  my $seq_obj = Bio::Seq->new(-display_id => $header,
                              -seq => $sequence);
  return $seq_obj;
}

#####
# getAtom
#
########
sub getAtom
{
  my $PDB = ParsePDB->new (FileName => shift @_);
  my $atom_num = shift @_;
  $PDB->Parse;
  return $PDB->Get(AtomNumber => $atom_num);
}

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
#   if "qt" is provided, treats as pdbqt file
#  Parses components into array bsed on PDB file format
#  Returns array
######
sub parseAtom
{
  my $isQt = 0;
  if(scalar(@_) == 2)
  {
    $isQt = 1;
  }
  my @data = split(//,shift @_);
  my @parsedData;
  ##
  # PDB file format is based on explicit spacing, not just tab-delimited
  #   Format documentation can be found: http://www.wwpdb.org/documentation/format33/sect9.html#ATOM
  #
  # PDBQT file format is similar, except in columns 71-79 inclusive
  #   Documentation here: http://autodock.scripps.edu/faqs-help/faq/what-is-the-format-of-a-pdbqt-file/
  #######
  push(@parsedData,join("",@data[0..5]));   # [0]  "ATOM  "
  push(@parsedData,join("",@data[6..10]));  # [1]  Atom serial number
  push(@parsedData,join("",@data[12..15])); # [2]  Atom name
  push(@parsedData,join("",$data[16]));     # [3]  Alternate location indicator
  push(@parsedData,join("",@data[17..19])); # [4]  Residue name
  push(@parsedData,join("",$data[21]));     # [5]  Chain identifier
  push(@parsedData,join("",@data[22..25])); # [6]  Residue sequence number
  push(@parsedData,join("",$data[26]));     # [7]  Code for insertion of residues
  my $x = join("",@data[30..37]);
  $x =~ s/\s*(\w+)\s*/$1/;
  push(@parsedData,$x);                     # [8]  X coordinate (in Angstroms)
  my $y = join("",@data[38..45]);
  $y =~ s/\s*(\w+)\s*/$1/;
  push(@parsedData,$y);                     # [9]  Y coordinate (in Angstroms)
  my $z = join("",@data[46..53]);
  $z =~ s/\s*(\w+)\s*/$1/;
  push(@parsedData,$z);                     # [10] Z coordinate (in Angstroms)
  push(@parsedData,join("",@data[54..59])); # [11] Occupancy
  push(@parsedData,join("",@data[60..65])); # [12] Temperature factor
  if($isQt) # PDBQT file
  { 
    push(@parsedData,join("",@data[70..75])); # [13] partial charge, %6.3f format
    push(@parsedData,join("",@data[77..78])); # [14] AutoDock atom-type
  }
  else # regular PDB file
  {
    push(@parsedData,join("",@data[76..77])); # [13] Element symbol, right-justified
    push(@parsedData,join("",@data[78..79])); # [14] Charge on the atom
  }

  return @parsedData;
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
  #   Format documentation can be found: http://www.wwpdb.org/documentation/format33/sect5.html#HELIX
  #######
  push(@parsedData,join("",@data[0..5]));    # [0]  "HELIX "
  push(@parsedData,join("",@data[7..9]));    # [1]  Helix serial number 
  push(@parsedData,join("",@data[11..13]));  # [2]  Helix identifier
  push(@parsedData,join("",@data[15..17]));  # [3]  Initial residue name
  push(@parsedData,$data[19]);               # [4]  Chain ID for chain containing this helix
  push(@parsedData,join("",@data[21..24]));  # [5]  Sequence number of the initial residue
  push(@parsedData,$data[25]);               # [6]  Insertion code of the initial residue
  push(@parsedData,join("",@data[27..29]));  # [7]  Terminal residue name
  push(@parsedData,$data[31]);               # [8]  Chain ID for chain containing this helix
  push(@parsedData,join("",@data[33..36]));  # [9]  Sequence number of terminal residue
  push(@parsedData,$data[37]);               # [10] Insertion code of terminal residue
  push(@parsedData,join("",@data[38..39]));  # [11] Helix class
  push(@parsedData,join("",@data[40..69]));  # [12] Comment
  push(@parsedData,join("",@data[71..75]));  # [13] Length of helix

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
