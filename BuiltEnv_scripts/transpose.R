#!/usr/bin/env Rscript
data <- t(read.delim("tmp",row.names=NULL,header=F))
data <- data[1:8,]
write.table(data,"replot",col.names=F,row.names=F,quote=F,sep="\t")
