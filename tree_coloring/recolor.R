#!/usr/bin/env Rscript
args <- as.vector(commandArgs(trailingOnly=TRUE))
colorlist <- read.delim("colorlist")
colorRGB <- as.vector(colorlist$colorRGB)
colorName <- as.vector(colorlist$colorName)
colorGroup <- as.vector(colorlist$group)
num <- as.numeric(args[1])
col <- args[2]
num
col
colorName[num] <- col
colorRGB[num] <- paste(t(unlist(col2rgb(colorName[num]))),collapse=" ")
colorlistNew <- data.frame("colorRGB"=unlist(colorRGB),"colorName"=unlist(colorName),"group"=unlist(colorGroup))
write.table(colorlistNew,file="colorlist",row.names=F,quote=F,sep="\t")
system("colormap.pl -i id2group.tsv")
system("colorTree_linux_x86_64 -i newickTree -c DendroColor.config -o colored_tree -f newick")
#system("Dendroscope -x \"open file=colored_tree.dendro\" &")
system("plotTree.R")
