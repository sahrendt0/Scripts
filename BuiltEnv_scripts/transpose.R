#!/usr/bin/env Rscript
data <- t(read.delim("tmp",row.names=NULL,header=F))
nr <- nrow(data)
data <- data[-nr,]
write.table(data,"replot",col.names=F,row.names=F,quote=F,sep="\t")
