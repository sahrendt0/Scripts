# Description: Uses ape package to color a tree based on a specific color scheme
#install.packages("ape")
library(ape)
myTree <- read.tree("RAxML_bestTree.mafft.trim.rxml.newick")
colorConfig <- read.delim("colorMap.config",sep="\t",header=T)
colorCode <- as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Color[which(x == colorConfig$Taxa)])))
label <- as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Order[which(x == colorConfig$Taxa)])))
plot(myTree,show.tip.label=FALSE);tiplabels(col=colorCode,frame="n",text=label,cex=0.6,adj=-0.05)
