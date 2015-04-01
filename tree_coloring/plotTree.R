#!/usr/bin/env Rscript
# Description: Uses ape package to color a tree based on a specific color scheme
#install.packages("ape")
library(ape)

## Read in Newick tree
myTree <- read.tree("newickTree")

## Read in colorconfig files and set up tip label <=> color map
colorConfig <- read.delim("colorMap.config",sep="\t",header=T,comment.char="")
colorCode <- as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Color[which(x == colorConfig$Taxa)])))
label <- as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Taxa[which(x == colorConfig$Taxa)])))

pdf(file="plot.pdf",60,30)
plot(myTree,show.tip.label=FALSE)

## label tips w/ names
tiplabels(col=colorCode,frame="n",text=label,cex=0.8,adj=-0.05)

## label nodes w/ bootstrap values >= 45
nodelabels(text=myTree$node.label[which(as.integer(myTree$node.label) >= 45)],node=(which(as.integer(myTree$node.label) >= 45)+myTree$Nnode+2),bg="white",frame="none",adj=c(1.1,1.5))

## Scale bar
add.scale.bar(x=5,y=3,length=1,pos=1)

## Making the legend
groups <- sort(unique(as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Group[which(x == colorConfig$Taxa)])))))
leg_cols <- unique(as.vector(unlist(lapply(groups,function(x) colorConfig$Color[which(x == colorConfig$Group)]))))
legend("topright",legend=groups,cex=1,text.col=leg_cols)
dev.off()

## Launch pdf viewer
system("evince plot.pdf &")
