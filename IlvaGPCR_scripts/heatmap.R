#!/usr/bin/env Rscript
## Used for generating heatmap plots for Cabrera et al GPCR paper
#######################################
library(gplots)
library(fastcluster)
library(RColorBrewer)
library(pheatmap)   
library(ape)


palette <- colorRampPalette(c('blue','white','red'))(100)

png("Townsend.png", width=1200, height=1800, units="px",res=300)
timeLabels <- c("0h", "2h", "24h", "48h", "72h", "96h", "120h", "144h")
townsend <- read.table("Townsend_enrich.dat",header=T,sep="\t",row.names=1);
gm <- data.matrix(townsend);
ch <- 10
cw <- 10
fontsize_row = 6 
fontsize_col = 6
pheatmap(gm, main="Townsend", 
         fontsize_row = fontsize_row,
         fontsize_col = fontsize_col,
         cluster_cols = FALSE, cluster_rows = TRUE,
         col = palette, scale="row",
         cellheight = ch,
         cellwidth  = cw,
         labels_col=timeLabels
         );
dev.off()

png("Kasuga.png", width=1000, height=1200, units="px",res=300)
timeLabels <- c("1h", "3h", "9h", "15h", "21h", "27h")
kas <- read.table("Kasuga_enrich.dat",header=T,sep="\t",row.names=1);
gm <- data.matrix(kas);
ch <- 10
cw <- 10
fontsize_row = 6 
fontsize_col = 6 
pheatmap(gm, main="Kasuga", 
         fontsize_row = fontsize_row,
         fontsize_col = fontsize_col,
         cluster_cols = FALSE, cluster_rows = TRUE,
         col = palette, scale="row",
         cellheight = ch,
         cellwidth  = cw,
         labels_col=timeLabels
         );
dev.off()
