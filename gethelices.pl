#!/usr/bin/perl
# Merge this with the new script
####################################
use warnings;
use strict;
use ParsePDB;
use Getopt::Long;

my $input; #helix file
my $spec;
my %helix_data;
my $help=0;
my $limit = 9; # index of hel desc and also number of structure files
my $model;
GetOptions ("i|input=s"   => \$input,  # helix file
            "s|species=s" => \$spec, # species (eg. Bd, Sp, etc)
            "m|model=s"   => \$model,
            "h|help+"     => \$help);

if($help)
{
  print "Usage: gethelices.pl -i input -s spec -m model\n";
  exit;
}

## Step 1. Open helix description file
open(HEL, "<$input") || die "Can't open $input\n";
my $lc = 0;
my @sp_keys;

while (my $line = <HEL>)
{
  next if (($line =~ m/^#/) || ($line =~ m/^\//));
  chomp $line;
  #print $line,"\n";
  if($lc == 0)
  {
    @sp_keys = split(/\s+/,$line);
  }
  else
  {
    my @coords = split(/\s+/,$line); 
    for(my $k=0;$k<$limit;$k++)
    {
      #print $sp_keys[$k],"\t",$coords[$limit],"\t",$coords[$k],"\n";
      $helix_data{$sp_keys[$k]}{$coords[$limit]} = $coords[$k];
      #$data{$k}{$coords[5]} = $coords{index_of{$k}};
    }
  }
  $lc++;
}
close(HEL);

$helix_data{$spec}{'model'} = $model;

## Step 2. Open pdbfile
my $pdbfile = $helix_data{$spec}{'model'};
my $PDB = ParsePDB->new (FileName => $pdbfile);
#$PDB->RenumberChains;
$PDB->Parse;
#print "sele $spec\_pocket, resi ";
foreach my $key (sort keys $helix_data{$spec})
{
  next if ($key !~ m/^H/);
  #print $key,"\n";  
  my ($start,$stop) = split(/\./,$helix_data{$spec}{$key});
  #print $start,"-",$stop,"+";
  for(my $r=($start-1);$r<$stop;$r++)
  {
    print $PDB->Get (Residue => $r);
  }
}
#print " in \n";
