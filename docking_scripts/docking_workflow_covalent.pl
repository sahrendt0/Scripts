#!/usr/bin/perl
# Script: docking_workflow_covalent.pl
# Description: Automatically do covalent docking
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.26.13
######################################
# Manual tasks:
#  - Determine critical atom number
#  - pass as argument -a
#  - change interacting atom to Z
################################
# Usage: docking_workflow.pl -l ligand -la ligand_abbr -r receptor -ra receptor_abbr -g reference_gpf -a critical_atom_num
################################
# Do not use extensions on the ligand or receptor
################################
use warnings;
use strict;
use Getopt::Long;
use PDBAnalysis;

#########
# Setup #
#########

#####-----Global Variables-----#####
my ($ligand, $lig, $receptor, $rec, $ref_gpf);
my $crit_atom; # number of receptor critical atom
my ($help,$verb,$bound);
my $box = 60;       # Box size
my $ga_run = 100;   # number of genetic algorithm runs
my $ga_gen = 27000; # maximum number of generations

GetOptions ('l|ligand=s'   => \$ligand, 
            'la|labbr=s'   => \$lig,
            'r|receptor=s' => \$receptor,
            'ra|rabbr=s'   => \$rec,
            'g|gpf=s'      => \$ref_gpf,
            'h|help'       => \$help,
            'v|verbose'    => \$verb,
            'a|atom=s'     => \$crit_atom,
            'b|box=s'      => \$box,
            'gr|grun=s'    => \$ga_run,
            'gg|ggen=s'    => \$ga_gen,
            'bo|bound'     => \$bound);

my $usage = "Usage: docking_workflow.pl -l ligand -la ligand_abbr -r receptor -ra receptor_abbr -a critical_atom\nDo not use extensions on the ligand or receptor\n";
die $usage if($help);

#####-----Main-----#####
########################
## 1. Prepare receptor
#########################
my $prep_rec = "prepare_receptor4.py -r $receptor\.pdb -A hydrogens";
if($verb){print "$prep_rec\n";}
system($prep_rec);

############################
## 2a. Store critical atom & parse coordinates 
#############################
my $r_atom = (getAtom("$receptor\.pdb",$crit_atom))[0];
chomp($r_atom);
open(ATOM,">ATOM");
print ATOM "#$receptor critical atom\n";
print ATOM "$r_atom\n";
close(ATOM);
my @r_atom_data = parseAtom($r_atom); # X,Y,Z at indices 8,9,10 
my $rx = $r_atom_data[8];
my $ry = $r_atom_data[9];
my $rz = $r_atom_data[10];
#print join(":",$rx,$ry,$rz),"\n";

##########################
# 2b. Remove atom line from PDBQT file
open(PDBQT,"<$receptor\.pdbqt") or die "Can't open $receptor\.pdbqt.\n";
open(TMP,">tmp");
while(my $line = <PDBQT>)
{
  chomp $line;
  next if ($line =~ /^TER/);
  my @data = parseAtom($line,"qt");
  next if (($data[8] == $rx) && ($data[9] == $ry) && ($data[10] == $rz));
  print TMP "$line\n";
}
my $append = "tail -1 $receptor\.pdbqt >> tmp";
system($append);
close(PDBQT);
close(TMP);
my $mv_rec = "mv tmp $receptor\.pdbqt";
system($mv_rec);

##########################
## 3a. Prepare ligand
########################
my $prep_lig = "prepare_ligand4.py -l $ligand\.mol2 -C";
system($prep_lig);

################
# 3b. Modify ligand
open(LIG_ATOM,"<LIG_ATOM") or die "Can't open LIG_ATOM. Did you forget to prepare it first?\n";
my @l_atom_data;
while (my $line = <LIG_ATOM>)
{
  next if ($line =~ /^#/);
  chomp $line;
  @l_atom_data = split(/\s+/,$line); # X,Y,Z at indices 2,3,4
  $l_atom_data[2] = sprintf("%.3f", $l_atom_data[2]);
  $l_atom_data[3] = sprintf("%.3f", $l_atom_data[3]);
  $l_atom_data[4] = sprintf("%.3f", $l_atom_data[4]);
}
close(LIG_ATOM);

open(LIG,"<$ligand\.pdbqt") or die "Can't open $ligand\.pdbqt: $!\n";
open(TMP,">tmp");
while(my $line = <LIG>)
{
  chomp $line;
  if ($line =~ /^ATOM/)
  {
    my @data = parseAtom($line,"qt");
    if (($data[8] == $l_atom_data[2]) && ($data[9] == $l_atom_data[3]) && ($data[10] == $l_atom_data[4]))
    {
      my @new = split(//,$line);
      $line = join("",@new[0..76],"Z ");
    }
  }
  print TMP $line,"\n";
  
}
close(LIG);
close(TMP);
my $mv_lig = "mv tmp $ligand\.pdbqt";
system($mv_lig);


####################
## 4. Prepare gpf
####################
# Box size: 60x60x60
# Center at receptor critical atom
my $prep_gpf = join(" ",
                    "prepare_gpf4.py",
                    "-l $ligand\.pdbqt",
                    "-r $receptor\.pdbqt",
                    "-p npts=$box,$box,$box",
                    "-p gridcenter=$rx,$ry,$rz",
                    "-p spacing=0.5",
                    "-o $rec\_$lig\_grid.gpf");
if($verb){print "$prep_gpf\n";}
system($prep_gpf);

open(GPF,">>$rec\_$lig\_grid.gpf");
print GPF "covalentmap 13.0 1000.0 $rx $ry $rz";
close(GPF);

###################
## 5. Prepare dpf
###################
my $prep_dpf = join(" ",
                    "prepare_dpf4.py",
                    "-l $ligand\.pdbqt",
                    "-r $receptor\.pdbqt",
                    "-p ga_run=$ga_run",
                    "-p ga_num_generations=$ga_gen",
                    "-o $rec\_$lig\_dock.dpf");
if($verb){print "$prep_dpf\n";}
system($prep_dpf);

if($bound)
{
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
}

=begin comment
my $grid = "autogrid4 -p $rec\_$lig\_grid.gpf -l $rec\_$lig\_grid.glg";
print `$grid`;
my $dock = "autodock4 -p $rec\_$lig\_dock.dpf -l $rec\_$lig\_dock.dlg";
print `$dock`;
=end comment
=cut

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
