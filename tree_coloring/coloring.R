#!/usr/bin/env Rscript
# Description: Reads in a list of the uniq groups found in a tree
addPrimaryKey <-function(df, cols){
   q<-apply(df[,cols], 1, function(x) paste(x, collapse=" "))
   df<-cbind(q, df)
   return(df)
}
uniqGroup <- readLines("uniqGroups")
colorsGroup <- sample(colors(TRUE),length(uniqGroup))
colorsRGB <- t(unlist(col2rgb(colorsGroup)))
colorsRGB <- as.data.frame(addPrimaryKey(colorsRGB,c(1,2,3)))
df <- data.frame("colorRGB"=unlist(colorsRGB$q),"colorName"=unlist(colorsGroup),"group"=unlist(uniqGroup))
write.table(df,file="colorlist",row.names=F,quote=F,sep="\t")
