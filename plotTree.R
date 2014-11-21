# Description: Uses ape package to color a tree based on a specific color scheme
#install.packages("ape")
library(ape)
myTree <- read.tree("RAxML_bestTree.mafft.trim.rxml2.newick")
colorConfig <- read.delim("colorMap.config",sep="\t",header=T)
colorCode <- as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Color[which(x == colorConfig$Taxa)])))
label <- as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Taxa[which(x == colorConfig$Taxa)])))

pdf(file="plot.pdf",30,10)
plot(myTree,show.tip.label=FALSE)
tiplabels(col=colorCode,frame="n",text=label,cex=0.7,adj=-0.05)
add.scale.bar()

## Making the legend
orders <- unique(as.vector(unlist(lapply(myTree$tip.label,function(x) colorConfig$Order[which(x == colorConfig$Taxa)]))))
leg_cols <- unique(as.vector(unlist(lapply(orders,function(x) colorConfig$Color[which(x == colorConfig$Order)]))))
legend("center",legend=orders,cex=1,text.col=leg_cols)
dev.off()
