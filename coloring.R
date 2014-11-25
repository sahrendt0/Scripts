uniqGroup <- readLines("colorlistPhylum")
colorsGroup <- sample(colors(TRUE),length(uniqGroup))
df <- data.frame("colors"=unlist(colorsGroup),"group"=unlist(uniqGroup))
write.table(df,file="colorlistPhylum.tmp",row.names=F,quote=F,sep="\t")
