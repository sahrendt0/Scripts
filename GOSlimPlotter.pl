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
my $plotfile = "GOPlot.pdf";
my $font_size = 1;
my @width_height = (15,30);
my $margins = "c(5,20,2,5)";  #bottom,left,top,right
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
my $spec = (split(/\_/,$GOIDs))[0];  # Specides being queried
my $slim_type = (split(/[\_\.]/,$GOSlim))[1];  # Slim type being used

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
  sortTypes($type);
}
drawPlot();
close(RSCRIPT);

## Execute the script
`chmod 744 $plot_script`;
`./$plot_script` if $exec;

## View pdfs
`evince $plotfile` if $view;

warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub sortTypes {
  my $GOType = shift @_;
  print RSCRIPT "$GOType\_sorted <- GOSlim_$GOType\[with(GOSlim_$GOType, order(Count)), ]\n";
  print RSCRIPT "if(length(which(GOSlim_$GOType\$Count == 0)) != 0) {\n";
  print RSCRIPT "$GOType\_sorted <- $GOType\_sorted[-which($GOType\_sorted\$Count == 0),]\n";  # Remove rows which have 0 count values
  print RSCRIPT "}\n";
}

sub drawPlot {
  #my $GOType = shift @_;
  my ($w,$h) = @width_height;  # page width and height values
  ## Set up plotting data
  my @types = sort keys %colors;
  print RSCRIPT "data <- c(log10($types[0]\_sorted\$Count),log10($types[1]\_sorted\$Count),log10($types[2]\_sorted\$Count))\n";
  print RSCRIPT "left_labels <- c(as.vector($types[0]\_sorted\$Term),as.vector($types[1]\_sorted\$Term),as.vector($types[2]\_sorted\$Term))\n";
  print RSCRIPT "right_labels <- c($types[0]\_sorted\$Count,$types[1]\_sorted\$Count,$types[2]\_sorted\$Count)\n";
  print RSCRIPT "ymax <- sum(length($types[0]\_sorted\$Count),length($types[1]\_sorted\$Count),length($types[2]\_sorted\$Count))\n";
  print RSCRIPT "colors <- c(rep(\"$colors{$types[0]}\",length($types[0]\_sorted\$Count)),rep(\"$colors{$types[1]}\",length($types[1]\_sorted\$Count)),rep(\"$colors{$types[2]}\",length($types[2]\_sorted\$Count)))\n";
  print RSCRIPT "pdf(\"$plotfile\",width=$w,height=$h)\n";
  print RSCRIPT "par(mar=$margins)\n";   # set margins
  print RSCRIPT "bplot <- barplot(width=0.8,ylim=c(0,ymax),xlim=c(0,4),data,horiz=TRUE,beside=FALSE,col=colors,yaxt=\"n\",main=\"$spec -vs- $slim_type\")\n";
  print RSCRIPT "axis(2,at=bplot,labels=left_labels,cex.axis=$font_size,las=2,tick=FALSE)\n";
  print RSCRIPT "axis(4,at=bplot,labels=right_labels,cex.axis=$font_size,las=2,tick=FALSE)\n";
  print RSCRIPT "dev.off()\n";
}
