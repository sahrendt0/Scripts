#!/usr/bin/perl
# Script: docking_workflow.pl
# Description: Automatically runs through autogrid and autodock to remove the need for the GUI steps in docking
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 3.22.13
#       5.23.14 :  updated; include shell script mode
#                  Try to automate some more
######################################
# Manual tasks:
#  - Determine grid coordinates and save as refence gpf
#  - Save macromolecule as pdbqt
################################
# Usage: docking_workflow.pl -l ligand -la ligand_abbr -r receptor -ra receptor_abbr -g reference_gpf
################################
# Do not use extensions on the ligand or receptor
################################

use warnings;
use strict;
use Getopt::Long;


#########
# Setup #
#########

my ($ligand, $lig, $receptor, $rec, $ref_gpf); 
my ($help,$shell);
my $covex;
GetOptions ('l|ligand=s'   => \$ligand, 
            'la|labbr=s'   => \$lig,
            'r|receptor=s' => \$receptor,
            'ra|rabbr=s'   => \$rec,
            'g|gpf=s'      => \$ref_gpf,
            'c|covex'     => \$covex,
            'h|help'      => \$help,
            's|shell'     => \$shell);

if($help)
{
  print "Usage: docking_workflow.pl -l ligand -la ligand_abbr -r receptor -ra receptor_abbr -g reference_gpf\n";
  print "Do not use extensions on the ligand or receptor\n";
  exit;
}

## Convert ligand to .pdbqt:
my $prep_rec = "prepare_receptor4.py -r";

my $prep_lig = "prepare_ligand4.py -l $ligand\.mol2 -C";

## Set up gpf file:
my $prep_gpf = join(" ","prepare_gpf4.py",
                           "-l $ligand\.pdbqt",
                           "-r $receptor\.pdbqt",
                           "-i $ref_gpf",
                           "-o $rec\_$lig\_grid.gpf");

## Set up autogrid:
my $autogrid = "autogrid4 -p $rec\_$lig\_grid.gpf -l $rec\_$lig\_grid.glg";

## Set up dpf file:
my $prep_dpf = join(" ","prepare_dpf4.py",
                           "-l $ligand\.pdbqt",
                           "-r $receptor\.pdbqt",
                           "-o $rec\_$lig\_dock.dpf", # output filename
                           "-p ga_run=100");  # 100 LGA runs

## Set up autodock
my $autodock = "autodock4 -p $rec\_$lig\_dock.dpf -l $rec\_$lig\_dock.dlg";

###########
# Running #
###########
## Prepare ligand
if(!$shell)
{
  print `$prep_lig`;
  print `$prep_gpf`;
  print `$autogrid`;
  print `$prep_dpf`;
  ##  Post processing of dpf: set "unbound_model" value to "bound" (as it should be by default), not "extended"
  open(DPF,"<$rec\_$lig\_dock.dpf") || die "Can't open dpf\n";
  open(TMP,">tmp");
  foreach my $line (<DPF>)
  {
    chomp $line;
    my $newline = $line;
    if($line =~ m/^unbound_model/)
    {
      my($param,$value,@ar) = split(/\s/,$line);
      $newline = join(" ",$param,"bound",@ar);
    }
    print TMP "$newline\n";
  }
  close(TMP);
  close(DPF);
  print `mv tmp $rec\_$lig\_dock.dpf`;
  print `$autodock`;
} 
else
{
  open(my $sh, ">", "$rec\_$lig.sh");
  print $sh "ln -s ../$receptor\.pdbqt\n";
  print $sh "ln -s ../$ref_gpf\n";
  print $sh "$prep_lig\n";
  print $sh "$prep_gpf\n";
  print $sh "$autogrid\n";
  print $sh "$prep_dpf\n";
  print $sh "sed -ie 's/extended/bound/g' $rec\_$lig\_dock.dpf\n";
  print $sh "$autodock\n";
  close($sh);
  print `chmod 744 $rec\_$lig.sh`;
}
