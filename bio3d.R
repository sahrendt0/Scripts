# Description: Loads Bio3D module and runs through steps to generate PCA plot
library(bio3d)
pdblist <- readLines("pdblist")
pdbs <- pdbaln(pdblist)	# msa using MUSCLE
gaps.pos <- gap.inspect(pdbs$xyz)
core <- core.find(pdbs, stop.at=1)
xyz <- fit.xyz(fixed=pdbs$xyz[1,],mobile=pdbs,fixed.inds=core$c1A.xyz,mobile.inds=core$c1A.xyz,pdb.path="",pdbext="",outpath = "corefit/",full.pdbs=TRUE,het2atom=TRUE)
pc.xray <- pca.xyz(xyz[, gaps.pos$f.inds])
