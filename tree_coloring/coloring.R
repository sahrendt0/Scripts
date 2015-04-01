#!/usr/bin/env Rscript
# Description: Reads in a list of the uniq groups found in a tree
library(RColorBrewer)
addPrimaryKey <-function(df, cols){
   q<-apply(df[,cols], 1, function(x) paste(x, collapse=" "))
   df<-cbind(q, df)
   return(df)
}
uniqGroup <- readLines("uniqGroups")
totalColors <- c(brewer.pal(8,"Dark2"),brewer.pal(12,"Paired"))
colorsGroup <- sample(totalColors,length(uniqGroup))
colorsRGB <- t(unlist(col2rgb(colorsGroup)))
colorsRGB <- as.data.frame(addPrimaryKey(colorsRGB,c(1,2,3)))
df <- data.frame("colorRGB"=unlist(colorsRGB$q),"colorName"=unlist(colorsGroup),"group"=unlist(uniqGroup))
write.table(df,file="colorlist",row.names=F,quote=F,sep="\t")
