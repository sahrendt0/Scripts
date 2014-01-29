#!/usr/bin/perl 
# Script: getaccnos.pl
# Description: Gets names of all sequences in a .fasta file (this is done using seqcount.pl as well)
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 9.2.13
#####################################
# Usage: getaccnos.pl -i seqfilename
#####################################
use warnings;
use strict;
use Bio::Perl;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

my $seqfilename;
my $help;

GetOptions ("i|input=s" => \$seqfilename,
            "h|help"   => \$help);

my $usage = "Usage: getaccnos.pl -i seqfilename\n";
die $usage if $help;
die $usage if (!$seqfilename);

my $seqfile = Bio::SeqIO->new(-file=>$seqfilename,
                              -format=>'fasta');
while (my $seq_obj = $seqfile->next_seq)
{
  print $seq_obj->display_id,"\n";
}

warn "Done.\n";
exit(0);
