#!/usr/bin/perl
# Script: mkpm.pl
# Description: Sets up a perl module template with comments and standard info
#########################
use strict;
use warnings;

my $name = shift @ARGV;
my $mod = (split(/\./,$name))[0];
open (OUT,">$name");
print OUT 'package '.$mod.';
# Name: '.$name.'
# Description:
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date:
#######################
use strict;
use base \'Exporter\';  # to export our subroutines

our @EXPORT; # export always
our @EXPORT_OK; # export sometimes

1;';

close(OUT);
