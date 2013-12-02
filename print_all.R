# Description: Loads Bio3D module and plots PCA using a variety of pre-defined color schemes
library(bio3d)
## Read colors
colors <- readLines("colors")
colors2 <- readLines("colors2")
colors3 <- readLines("colors3")
## Write original, full, colorscheme 1
pdf(file="pca.pdf")
plot(pc.xray,pch=19,col=colors)
dev.off()
## Write original, full, colorscheme 3
pdf(file="pca_c3.pdf")
plot(pc.xray,pch=19,col=colors3)
dev.off()
## Print 1v2, no labels, colorscheme 1
pdf(file="pca12.pdf")
plot(pc.xray$z[,1],pc.xray$z[,2],col=colors,pch=19)
dev.off()
## Print 1v2, no labels, colorscheme 3
pdf(file="pca12_c3.pdf")
plot(pc.xray$z[,1],pc.xray$z[,2],col=colors3,pch=19)
dev.off()
## Print 1v2, labels, colorscheme1
pdf(file="pca12_labels.pdf")
plot(pc.xray$z[,1],pc.xray$z[,2],col=colors,pch=19)
text(pc.xray$z[,1],pc.xray$z[,2],labels = pdblist,cex=0.5,pos=1)
dev.off()
## Print 1v3, no labels, colorscheme 1
pdf(file="pca13.pdf")
plot(pc.xray$z[,1],pc.xray$z[,3],col=colors,pch=19)
dev.off()
## Print 1v3, no labels, colorscheme 3
pdf(file="pca13_c3.pdf")
plot(pc.xray$z[,1],pc.xray$z[,3],col=colors3,pch=19)
dev.off()
## Print 1v3, labels, colorscheme 1
pdf(file="pca13_labels.pdf")
plot(pc.xray$z[,1],pc.xray$z[,3],col=colors,pch=19)
text(pc.xray$z[,1],pc.xray$z[,3],labels = pdblist,cex=0.5,pos=1)
dev.off()
## Print 2v3, no labels, colorscheme 1
pdf(file="pca23.pdf")
plot(pc.xray$z[,3],pc.xray$z[,2],col=colors,pch=19)
dev.off()
## Print 2v3, no labels, colorscheme 3
pdf(file="pca23_c3.pdf")
plot(pc.xray$z[,3],pc.xray$z[,2],col=colors3,pch=19)
dev.off()
## Print 2v3, labels, colorscheme 1
pdf(file="pca23_labels.pdf")
plot(pc.xray$z[,3],pc.xray$z[,2],col=colors,pch=19)
text(pc.xray$z[,3],pc.xray$z[,2],labels = pdblist,cex=0.5,pos=1)
dev.off()
