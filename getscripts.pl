#!/usr/bin/perl -w
# Script: getscripts.pl
# Description: Produces scripts.txt containing all of the custom scripts in ~/scripts
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.24.13
#       v.1.0
#       v.1.1 Add support for R or C/C++ files
#       v.1.2 Change home dir
#       v.1.3 Add support for Ruby or Python files
#############################
# Usage: getscripts.pl
############################

use strict;

my $dir = ".";
my $ext = "[pl|c|R|rb|py]";

my @scripts = glob '*.{pl,c,R,rb,py}';
=begin COMMENT
opendir(DIR,$dir) or die "Can't open $dir\n";
my @scripts = grep { /\.$ext$/} readdir(DIR);
close(DIR);
=cut
@scripts = sort @scripts;
my $len = 0;
open(OUT,">scripts.txt");
print OUT "+-";
for(1..(length($dir)+16)){print OUT "-";}
print OUT "-+\n";
print OUT "| Custom scripts: $dir |\n";
print OUT "+-";
for(1..(length($dir)+16)){print OUT "-";}
print OUT "-+\n\n";
foreach my $script (@scripts)
{
	print OUT $script;
	#print "$script\n";	
	$len = length($script);
	#print "($len)";
	if(($len%2)==0)
	{
		while($len < 24)
		{
			print OUT ". ";
			$len+=2;		
		}
	}
	else
	{
		while($len < 23)
		{
			print OUT " .";
			$len+=2;
		}
		print OUT " ";
	}
	open(IN,"<$dir/$script") or die "Can't open $dir/$script..\n";
	foreach my $line (<IN>)
	{
		chomp($line);
		if($line =~ m/^[#|*]+ Description/i){print OUT substr($line,15);}
	}
	print OUT "\n";
	close(IN);
}
close(OUT);
