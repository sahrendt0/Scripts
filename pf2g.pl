#!/usr/bin/perl
# Script pf2g.pl
# Description: Takes a list of pfam IDs and maps them to go terms
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 10.23.13
##################################
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;

#####-----Global Variables-----#####
my $input; # command line input
my @pfamlist;
my $pfam2go = "/rhome/sahrendt/Data/GO/pfam2go";    # pfam2go mapping file
my ($help,$verb);
my %PFGOMAP;
GetOptions ('i|input=s' => \$input,
            'g|go=s'    => \$pfam2go,
            'h|help'    => \$help,
            'v|verbose' => \$verb);

my $usage = "pf2g.pl -i pfamlist [-g pfam2go]\n";
die $usage if $help;
die $usage if (!$input);

if(open(LIST,"<$input"))
{
  @pfamlist = <LIST>;
  chomp @pfamlist;
  close(LIST); 
}
else
{
  warn "Assuming $input is PFAM ID, not file\n";
  push (@pfamlist,$input);
}

## Setup hash for pfam2go data
makeHash($pfam2go);

## Print the GO IDs
printIDs(\@pfamlist);

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub printIDs {
  my @list = @{$_[0]};
  foreach my $PFID (@list)
  {
    $PFID =~ s/\.\d+//; # chomp off decimal number
    #print "$PFID\n";
    if (exists $PFGOMAP{$PFID})
    {
      my $numGO = scalar @{$PFGOMAP{$PFID}{"GO"}{"ids"}};
      for(my $i=0;$i<$numGO;$i++)
      {
        print $PFGOMAP{$PFID}{"GO"}{"ids"}[$i],"\n";
      }
    }
    else
    {
      warn "$PFID\n";
    }
  }
}

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
    my ($GOdesc,$GOID) = split(/ ; /,$go);
    $GOdesc =~ s/^\s//;
    #print "  $GOID--$GOdesc\n";
    $PFGOMAP{$PID}{"desc"} = $Pdesc;
    push (@{$PFGOMAP{$PID}{"GO"}{"ids"}}, $GOID);
    push (@{$PFGOMAP{$PID}{"GO"}{"desc"}},$GOdesc);
  }
  close(P2G);
}

