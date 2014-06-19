#!/usr/bin/env Rscript

library(ChemmineR);
args <- commandArgs(TRUE);
print(args[1]);
write.SDFsplit(x=read.SDFset(sdfstr=args[1]), filetag="A1_", nmol=1);
