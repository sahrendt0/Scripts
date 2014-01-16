#!/usr/bin/perl
# Script: mkpl.pl
# Description: Sets up perl skeleton script
use warnings;
use strict;
use Time::Piece;
use Getopt::Long;

my $date = Time::Piece->new->strftime('%m.%d.%Y');
my $input;
my $desc = "";

GetOptions ('i|input=s' => \$input,
            'd|description=s' => \$desc);

my $usage = "Usage: mkpl.pl -i input [-d desc]\n";
die "No input.\n$usage" if (!$input);


open(OUT,'>',$input);
print OUT '#!/usr/bin/perl
# Script: '.$input.'
# Description: '.$desc.' 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: '.$date.'
##################################
use warnings;
use strict;
use Getopt::Long;

#####-----Global Variables-----#####
my $input;
my ($help,$verb);

GetOptions (\'i|input=s\' => \\$input,
            \'h|help\'   => \\$help,
            \'v|verbose\' => \\$verb);
my $usage = "Usage: '.$input.' -i input\n";
die $usage if $help;
die "No input.\n$usage" if (!$input);

#####-----Main-----#####

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####';
close(OUT);

print `chmod 744 $input`;
