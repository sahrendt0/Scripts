#!/usr/bin/env Rscript
addPrimaryKey <-function(df, cols){
   q<-apply(df[,cols], 1, function(x) paste(x, collapse=" "))
   df<-cbind(q, df)
   return(df)
}
uniqGroup <- readLines("colorlistPhylum")
colorsGroup <- sample(colors(TRUE),length(uniqGroup))
colorsGroup <- t(unlist(col2rgb(sample(colors(TRUE),length(uniqGroup)))))
colorsRGB <- as.data.frame(addPrimaryKey(colorsGroup,c(1,2,3)))
df <- data.frame("colors"=unlist(colorsRGB$q),"group"=unlist(uniqGroup))
write.table(df,file="colorlistPhylum.tmp",row.names=F,quote=F,sep="\t")
