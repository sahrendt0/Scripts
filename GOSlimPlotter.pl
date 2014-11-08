#!/usr/bin/perl
# Script: GOSlimPlotter.pl
# Description: Creates separate GO barplots for a given set of GO IDs 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 11.07.2014
##################################
use warnings;
use strict;
use Getopt::Long;
use lib '/rhome/sahrendt/Scripts';

#####-----Global Variables-----#####
my $GOIDs;
my $GOSlim;
my $plot_script = "myPlot.R";
my %colors = ( "CC" => "red",
               "MF" => "cornflowerblue",
               "BP" => "green");
my ($help,$view,$exec);

GetOptions ('goids=s'   => \$GOIDs,
            'goslim=s'  => \$GOSlim,
            'h|help'    => \$help,
            'v|view'    => \$view,
            'e|execute' => \$exec);
my $usage = "Usage: GOSlimPlotter.pl --goids list_of_ids --goslim goSlim_file\nCreates separate GO barplots for a given set of GO IDs\n";
die $usage if $help;
die "No ids.\n$usage" if (!$GOIDs);
die "No slim file.\n$usage" if (!$GOSlim);

#####-----Main-----#####
my $spec = (split(/\_/,$GOIDs))[0];
`rm $plot_script` if(-e $plot_script);  # clear out the file so we don't blindly append to it
open(RSCRIPT,">>",$plot_script);
print RSCRIPT "#!/usr/bin/env Rscript\n";
print RSCRIPT "library(GSEABase)\n";
print RSCRIPT "GOIDs <- as.vector(readLines(\"$GOIDs\"))\n";
print RSCRIPT "Collection <- GOCollection(GOIDs)\n";
print RSCRIPT "slim <- getOBOCollection(\"$GOSlim\")\n";
foreach my $type (sort keys %colors)
{
  print RSCRIPT "GOSlim_$type <- goSlim(Collection, slim, \"$type\")\n";
  print RSCRIPT "write.table(GOSlim_$type,file=\"$spec\_$type\_$GOSlim\.tsv\",quote=F,sep=\"\\t\")\n";
  drawPlot($plot_script,$type,$colors{$type});
}
close(RSCRIPT);

## Execute the script
`chmod 744 $plot_script`;
`./$plot_script` if $exec;

## View pdfs
`evince *.pdf` if $view;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub drawPlot {
  my $RScript = shift @_;       # Rscript file name
  my $GOType = shift @_;
  my $RColor = shift @_;
  my $plotfile = "$GOType.plot.pdf";   # Name of pdf file to draw
  my ($w,$h) = (15,15);  # page width and height values
  my $font_size = 1;

  print RSCRIPT "$GOType\_sorted <- GOSlim_$GOType\[with(GOSlim_$GOType, order(Count)), ]\n";
  print RSCRIPT "if(length(which(GOSlim_$GOType\$Count == 0)) != 0) {\n";
  print RSCRIPT "$GOType\_sorted <- $GOType\_sorted[-which($GOType\_sorted\$Count == 0),]\n";  # Remove rows which have 0 count values
  print RSCRIPT "}\n";
  print RSCRIPT "pdf(\"$plotfile\",width=$w,height=$h)\n";
  print RSCRIPT "par(mar=c(5,10,2,5))\n";   # set margins
  print RSCRIPT "bplot <- barplot(log10($GOType\_sorted\$Count),horiz=TRUE,beside=FALSE,col=c(\"$RColor\"),yaxt=\"n\")\n";
  print RSCRIPT "axis(2,at=bplot,labels=$GOType\_sorted\$Term,cex.axis=$font_size,las=2,tick=FALSE)\n";
  print RSCRIPT "axis(4,at=bplot,labels=$GOType\_sorted\$Count,cex.axis=$font_size,las=2,tick=FALSE)\n";
  print RSCRIPT "dev.off()\n";
}
