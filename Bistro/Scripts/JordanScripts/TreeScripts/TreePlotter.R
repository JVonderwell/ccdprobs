#parses trees from both bistro and MB output for comparison

library(ggplot2)
library(ape)
library(phangorn)

bistroFile = "simWhales1500.bistroSum"
mbFile = "simWhales.mbSum"

bistroTable = read.table(bistroFile)
bistroTable = bistroTable[order(bistroTable$V2, decreasing=TRUE),]

##KEEP TRACK OF COMMANDS USED
mbProbs = c(0)
mbTrees = c("")
line = rep("", 5)
i = 0
while (line[1] != "Count") 
{
  line = scan(file=mbFile,what=character(),skip=i,nlines=1); i=i+1;
  if(is.na(line[1]) ) line[1] = " ";
}

j = 1

line = scan(file=mbFile,what=character(),skip=i,nlines=1); i=i+1;
while (!is.na(line[1]))
{
  mbProbs[j] = as.numeric(line[2]);
  mbTrees[j] = line[4];
  j = j+1;
  line = scan(file=mbFile,what=character(),skip=i,nlines=1); i=i+1;
}

mbTable = data.frame(mbTrees, mbProbs)

combinedTrees = c(" ")
mbProb = c(0)
bistroProb=c(0)
index = 1

allTrees = c(mbTrees, as.vector(bistroTable$V1))
bistroTable$V1 = factor(bistroTable$V1, levels=allTrees)
mbTable$mbTrees = factor(mbTable$mbTrees, levels=allTrees)

##loops over bistro table to get all of it's clades. if there's a match in mb
##use each probability. If no match, mbProb is set to 0
##note: this does not currently include mb trees that bistro does not also have
##since mb trees were usually found in bistro but not often vice versa
for (i in 1:dim(bistroTable)[1]) {
  tree = bistroTable$V1[i]
  bistrotree = read.tree(text=paste0(as.character(bistroTable$V1[i]),";"))
  if (bistroTable$V2[i] > 0.001) {
    combinedTrees[index] = as.character(tree)
    bistroProb[index] = bistroTable$V2[i]
    foundMatch = FALSE
    for (j in 1:dim(mbTable)[1]) {
      mbtree = read.tree(text=paste0(text=as.character(mbTable$mbTrees[j]),";"))
      if (RF.dist(bistrotree,mbtree) == 0) {
        mbProb[index] = mbTable$mbProbs[j]
       index = index+1
       foundMatch = TRUE
      }
    }
    if (!foundMatch) {
      mbProb[index] = 0
      index = index+1
    }
  }
}

combinedTable = data.frame(combinedTrees, mbProb, bistroProb)

plot(ggplot() +
  geom_point(data=combinedTable, aes(x=combinedTrees, y=mbProb), color='red') +
  geom_point(data=combinedTable, aes(x=combinedTrees, y=bistroProb), color='blue') +
  scale_color_manual(labels=c("Bistro", "MB"), values = c("blue", "red")) +  
  theme_bw() + 
  theme(axis.text.x=element_blank()))
