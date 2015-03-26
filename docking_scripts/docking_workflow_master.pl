#!/usr/bin/perl
# Script: docking_workflow_master.pl
# Description: Run through steps in docking workflow
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.25.15
######################################
# Manual tasks:
#  - Determine critical atom number
#  - pass as argument -a
#  - change interacting atom to Z
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
my ($ligand, $lig_ab, $receptor, $rec_ab, $ref_gpf);
my ($crit_atom,@RecCritXYZ); # number of receptor critical atom, and array containing its coordinates
my $lig_atom = "LIG_ATOM"; # file storing coords of binding atom in ligand (for covalent docking)
my ($help,$verb,$bound);
my $box = "60,60,60";       # Box size
my $ga_run = 100;   # number of genetic algorithm runs
my $ga_gen = 27000; # maximum number of generations

my $cov; # flag for covalent docking

my $prepGPF_script = "prepare_gpf4.py";
my $prepDPF_script = "prepare_dpf4.py";
my $prepRec_script = "prepare_receptor4.py";
my $prepLig_script = "prepare_ligand4.py";

GetOptions ('l|ligand=s'   => \$ligand, 
            'la|labbr=s'   => \$lig_ab, # ligand abbreviation
            'r|receptor=s' => \$receptor,
            'ra|rabbr=s'   => \$rec_ab, # receptor abbreviation,
            'g|gpf=s'      => \$ref_gpf,
            'h|help'       => \$help,
            'v|verbose'    => \$verb,
            'a|atom=s'     => \$crit_atom,
            'b|box=s'      => \$box,
            'gr|grun=s'    => \$ga_run,
            'gg|ggen=s'    => \$ga_gen,
            'bo|bound'     => \$bound,
            'covalent'     => \$cov);

my $usage = "Usage: docking_workflow.pl -r receptor -a crit_atom\nDo not use extensions on the ligand or receptor\n";
die $usage if($help);
#die "No critical atom provided; this is needed for centering\n$usage" if (!$crit_atom);
die "You've indicated covalent mode but no LIG_ATOM file was found.\n" if($cov && !-e $lig_atom);

#####-----Main-----#####

## Get critical atom coords
@RecCritXYZ = @{getCrit()};

## Prepare and receptor
prepReceptor();
$rec_ab = $receptor;

opendir(DIR,".");
my @ligands = grep { /A1_\d{3}/ } readdir(DIR);
closedir(DIR);
#print "@ligands";
foreach my $lig_dir (@ligands)
{
  $ligand = $lig_dir;
  $lig_ab = $ligand;
  print $ligand,"\t";
  
  ## This allows us to restart a run which had been ended previously
  my $logfile = "$rec_ab\_$lig_ab\_dock.dlg";
  
 # print `pwd`;
 # print `cd ./$ligand`;
  chdir("./$ligand") or die "$!";
 # if(-e $logfile) { print getLines($logfile),"\n";}
 # else { print "0\n"; }
  if(!-e $logfile || (getLines($logfile) < 100))
  {
    print `ln -s ../$receptor\.pdbqt`;

    ## Prepare ligand file
    prepLigand();

    ## If covalent, remove critical atom from pdbqt file
    removeCrit() if $cov;
 
    ## If covalent, modify the ligand file 
    modifyLigand() if $cov;
  
    ## Prepare gpf and dpf files
    prepGPF();
    prepDPF();

    ## Run autoGrid and autoDock
    runGrid();
    runDock();
  }
  chdir("..");
 # print `pwd`;
}
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub getLines {
  my $fname = shift @_;
  my $c = 0;
  open(my $fh, "<", $fname) or die "Can't open $fname: $!\n";
  $c = scalar( grep {$_ =~ /^Run:/} <$fh> );
  close($fh);
  return $c;
}
##########
## Subroutine: modify ligand file 
#    based on the binding atom location
################
sub modifyLigand {
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
}
#####
## Subroutine prepInput
##  Prepares the input files by running prepare_receptor4.py and prepare_ligand4.py
###########
sub prepReceptor {
  ## Prepare receptor
  my $prep_rec = "$prepRec_script -r $receptor\.pdb -A hydrogens";
  if($verb){print "$prep_rec\n";}
  system($prep_rec);
}
sub prepLigand {
  ## Prepare ligand
  my $prep_lig = "$prepLig_script -l $ligand\.mol2 -C";
  if($verb){print "$prep_lig\n";}
  system($prep_lig);
}

###
## Subroutine: remove critical atom
#    If covalent docking is required, need to remove the critical atom from the PDBQT file
########
sub getCrit {
  my $r_atom = (getAtom("$receptor\.pdb",$crit_atom))[0];
  chomp($r_atom);
  open(ATOM,">$receptor\_ATOM");
  print ATOM "#$receptor critical atom\n";
  print ATOM "$r_atom\n";
  close(ATOM);
  my @r_atom_data = parseAtom($r_atom); # X,Y,Z at indices 8,9,10 
  my @return = @r_atom_data[8..10];
  return \@return;
  #my $rx = $r_atom_data[8];
  #my $ry = $r_atom_data[9];
  #my $rz = $r_atom_data[10];
}

###
## Remove the critical atom from the pdbqt file
############
sub removeCrit {
  open(PDBQT,"<$receptor\.pdbqt") or die "Can't open $receptor\.pdbqt.\n";
  open(TMP,">tmp");
  while(my $line = <PDBQT>)
  {
    chomp $line;
    next if ($line =~ /^TER/);
    my @data = parseAtom($line,"qt");
    next if (($data[8] == $RecCritXYZ[0]) && ($data[9] == $RecCritXYZ[1]) && ($data[10] == $RecCritXYZ[2]));
    print TMP "$line\n";
  }
  my $append = "tail -1 $receptor\.pdbqt >> tmp";
  system($append);
  close(PDBQT);
  close(TMP);
  my $mv_rec = "mv tmp $receptor\.pdbqt";
  system($mv_rec);
}

####
## Prepare GPF file
##########
sub prepGPF {
  # Center at receptor critical atom
  my $prep_gpf = join(" ",
                      $prepGPF_script,
                      "-l $ligand\.pdbqt",
                      "-r $receptor\.pdbqt",
                      "-p npts=$box",
                      "-p gridcenter=\"",join(" ",@RecCritXYZ),"\"",
                      "-p spacing=0.5",
                      "-o $rec_ab\_$lig_ab\_grid.gpf");
  if($verb){print "$prep_gpf\n";}
  system($prep_gpf);
  if($cov)
  {
    open(GPF,">>$rec_ab\_$lig_ab\_grid.gpf");
    print GPF "covalentmap 13.0 1000.0 ",join(" ",@RecCritXYZ);
    close(GPF);
  }
}
###
## Run autogrid
#######
sub runGrid {
  my $grid = "autogrid4 -p $rec_ab\_$lig_ab\_grid.gpf -l $rec_ab\_$lig_ab\_grid.glg";
  print $grid,"\n" if $verb;
  system($grid);
}
### 
## Run autodock
########
sub runDock {
  my $dock = "autodock4 -p $rec_ab\_$lig_ab\_dock.dpf -l $rec_ab\_$lig_ab\_dock.dlg";
  print $dock,"\n" if $verb;
  system($dock);
}
####
## Prepare DPF file
##########
sub prepDPF {
  my $prep_dpf = join(" ",
                      $prepDPF_script,
                      "-l $ligand\.pdbqt",
                      "-r $receptor\.pdbqt",
                      "-p ga_run=$ga_run",
                      "-p ga_num_generations=$ga_gen",
                      "-o $rec_ab\_$lig_ab\_dock.dpf");
  if($verb){print "$prep_dpf\n";}
  system($prep_dpf);

  if($bound)
  {
    open(DPF,"<$rec_ab\_$lig_ab\_dock.dpf") || die "Can't open dpf\n";
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
    print `mv tmp $rec_ab\_$lig_ab\_dock.dpf`;
  }
}
