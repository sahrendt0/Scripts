#!/usr/bin/perl
# Script: mkpm.pl
# Description: Sets up a perl module template with comments and standard info 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 03.18.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use Time::Piece;

#####-----Global Variables-----#####
my $input;
my $desc = "";
my ($help,$verb);
my $date = Time::Piece->new->strftime('%m.%d.%Y');

GetOptions ('i|input=s' => \$input,
            'd|description=s' => \$desc,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: mkpm.pl -i input [-d description]\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####
my $mod = (split(/\./,$input))[0];
open (OUT,">$input");
print OUT 'package '.$mod.';
# Name: '.$input.'
# Description: '.$desc.'
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: '.$date.'
#######################
use strict;
use base \'Exporter\';  # to export our subroutines

our @EXPORT; # export always
our @EXPORT_OK; # export sometimes

1;';

close(OUT);

warn "Done.\n";
exit(0);

#####-----Subroutines-----######!/usr/bin/perl
