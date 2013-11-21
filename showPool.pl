#!/usr/bin/perl
# Script: showPool.pl
# Description: Takes pool input and highlights residues in Pymol
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.20.13
#        v.1.1:  give threshold in percent
#                - default will use 10% of residues
#                - force a number using -T (absolute threshold)
################################
# Rank	POOL score	Residue	Number	Annotation
################################

use warnings;
use strict;
use Getopt::Long qw(:config no_ignore_case);
use Math::Round;

#####-----Global Variables-----#####
my $PDBname;
my $tp = .10;  # percent of residues to use 
my $threshold; # number of residues to use
my ($poolfile, $PDBfile);
my ($help,$verb);
my @nums;  # array containing residue positions to display
my $lc = 0; # counter to ignore first line

GetOptions ('i|input=s'     => \$poolfile,
            'p|pdb=s'       => \$PDBfile,
            't|thresp=s'    => \$tp,
            'T|Threshold=s' => \$threshold,
            'v|verbose'     => \$verb,
            'h|help'        => \$help);

## Error checking
my $usage = "Usage: showPool.pl -i poolfile -p PDBfile [-t threshold_percent | -T threshold]\n";
die $usage if $help;
die "No PDB file\n$usage" if (!$PDBfile);
die "No POOL file\n$usage" if (!$poolfile);
if($tp)
{
  die "tp error\n$usage" if ($tp =~ /^-?\d+\z/);
}
if($threshold)
{
  die "Threshold error\n$usage" if ($threshold !~ /^-?\d+\z/);
}

#####-----Main-----#####
$PDBname = (split(/\./,$PDBfile))[0];
open(POOL,'<',$poolfile) or die "Can't open POOL file\n";
while(my $line = <POOL>)
{
  $lc++;
  next if ($lc == 1);
  chomp $line;
  my ($rank,$score,$resid,$resnum) = split(/\t/,$line);
  
  #print "$rank--$score--$resid--$resnum\n";
  push (@nums, $resnum);
}
close(POOL);

if(!$threshold)
{
  $threshold = round($tp*$lc);
  print "$tp * $lc = $threshold\n";
}
print "$threshold residues will be used\n";
__END__
my $run = "pymol $PDBfile -d 'run ~/Scripts/pdb_scripts/color_by_restype.py;
                              create pocket, resi ".join("+",@nums[0..($threshold-1)])." in $PDBname;
                              bg_color white;
                              hide everything;
                              show cartoon,$PDBname;
                              set cartoon_transparency, 0.75, $PDBname;
                              remove hydrogens;
                              show sticks, pocket;
                              color_by_restype pocket'";
#                              set label_font_id, 13;
#                              set label_outline_color, black;
#                              set label_size, 40;
#                              label n. ca, \"\%s\%s\" \%(one_letter[resn],resi);
#                              set ray_trace_mode,1;
#                              ray 1000,1000;
#                              png $PDBname\_pocket.png, dpi=300;
#                              quit'";

print $run,"\n";
print `$run`;
warn "Done\n";
exit(0);
