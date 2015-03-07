#!/usr/bin/env Rscript
library(bio3d)
pdblist <- readLines("pdblist")
pdbs <- pdbaln(pdblist)	# msa using MUSCLE
gaps.pos <- gap.inspect(pdbs$xyz)
core <- core.find(pdbs, stop.at=1)
xyz <- fit.xyz(fixed=pdbs$xyz[1,],mobile=pdbs,fixed.inds=core$c1A.xyz,mobile.inds=core$c1A.xyz,pdb.path="",pdbext="",outpath = "corefit/",full.pdbs=TRUE,het2atom=TRUE)
pc.xray <- pca.xyz(xyz[, gaps.pos$f.inds])
gaps <- unique( which(is.na(pdbs$xyz),arr.ind=TRUE)[,2] )
inds <- c(1:ncol(pdbs$xyz))[-gaps]
## Find PAirwise RMSD: fitted and non fitted
pw_rmsdMap <- rmsd(pdbs$xyz[,inds])
pw_rmsdMap_fit <- rmsd(pdbs$xyz[,inds],fit=TRUE)
## Generate heatmap (non-fitted)
pdf("RMSD_Heatmap.pdf")
heatmap(pw_rmsdMap,labRow=pdblist,labCol=pdblist,symm=TRUE)
dev.off()
## Write out table
pw_rmsd <- as.data.frame(pw_rmsdMap)
pw_rmsd_fit <- as.data.frame(pw_rmsdMap_fit)
colnames(pw_rmsd) <- pdbs$id; rownames(pw_rmsd) <- pdbs$id
colnames(pw_rmsd_fit) <- pdbs$id; rownames(pw_rmsd_fit) <- pdbs$id
write.table(pw_rmsd,file="pw_rmsd",quote=F,sep="\t")
