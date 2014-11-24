package General;
# Name: General.pm
# Description: Perl module containing often-used subroutines
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.24.14
#######################
use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw( indexOf);

sub indexOf {
  my $search_for = shift @_;
  my @array = @{shift @_};
  my( $index ) = grep { $array[$_] eq $search_for } 0..$#array;
  return $index;
}

1;
