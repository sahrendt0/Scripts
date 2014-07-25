#!/usr/bin/perl -w
# Script: getpdb.pl
# Description: Gathers PDB structure files from the Protein Data Bank (using wget)
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 8.27.13
#       v 1.0  : file-based input *MUST* be in a .txt file
#              : uses wget, so maybe not so good for a large number of IDs (use FTP instead?)
#       v 1.1  : restructured input so file does not need ".txt" extension
#       v 1.2  : added check for missing input
#       v 1.2.1: updated command line options
###################################################################################################
# Can provide as argument either a single PDB ID or a plain text file containing many such IDs
#   Additionally, can provide -v for "verbose": print which structures are being downloaded
#   If -v is absent, there will be no screen output
###################################################################################################
# Usage: getpdb.pl [-v] -i structure_id      #
#   or                                       #
# Usage: getpdb.pl [-v] -i structure_id_file #
##############################################

use strict;
use LWP::Simple;

# Handle command-line options
use Getopt::Long;
my $help = 0;
my $verbose = 0;
my $input;
GetOptions ("i|input=s"  => \$input,
            "h|help+"    => \$help,
            "v|verbose+" => \$verbose);

## If -v is provided, let the user know which structures are being downloaded
## Otherwise, run quietly
if($help)
{
  print "Usage: getpdb.pl [-v] -i structure_id\n";
  print "   or: getpdb.pl [-v] -i structure_id_file\n";
  exit;
}

if(open(LIST,"<$input"))
{
  foreach my $id (<LIST>)
  {
    getPDB($id,$verbose);
  }
  close(LIST);
}
else
{
  print "Can't find file \"$input\", so I'll assume that \"$input\" is a PDB code.\n";
  getPDB($input,$verbose);
}

sub getPDB
{
  my $pdbid = lc(shift);
  my $mode = shift;
  #print $mode;
  chomp($pdbid);
  if($pdbid !~ m/^\w{4}$/)
  {
    die "$pdbid not a valid PDB ID code\n"; 
  }
  my $url = "http://www.rcsb.org/pdb/files/$pdbid.pdb";
  if($mode) {print "wgetting $pdbid..";} # screen output
  print `wget -q $url`;
  my $updbid = uc($pdbid);
  print `mv $pdbid.pdb $updbid.pdb`;
  if($mode) {print "..OK\n";} # screen output
}
