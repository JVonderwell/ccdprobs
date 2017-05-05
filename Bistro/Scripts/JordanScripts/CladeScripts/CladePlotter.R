##parses clades from both bistro and mb output for comparison

library(ggplot2)

##output files from bistrocladeparser and mbcladeparser 
bistrofile = "simWhales1500.bistroClades"
mbfile = "simWhales1500.mbClades"

bistroTable = read.table(bistrofile)
bistroTable = bistroTable[order(bistroTable$V2, decreasing=TRUE),]

mbTable = read.table(mbfile)
mbTable = mbTable[order(mbTable$V2, decreasing=TRUE),]

combinedClades = c(" ")
mbProb = c(0)
bistroProb = c(0)
index = 1

allClades = c(as.vector(mbTable$V1), as.vector(bistroTable$V1))
bistroTable$V1 = factor(bistroTable$V1, levels=allClades)
mbTable$V1 = factor(mbTable$V1, levels=allClades)

##loops over mb table to get all of it's clades. if there's a match in bistro
##use each probability. If no match, bistroProb is set to 0
##note: this does not currently include bistro clades that mb does not also have
for (i in 1:dim(mbTable)[1]) {
  clade = mbTable$V1[i]
  if (mbTable$V2[i] > 0.001) {
    combinedClades[index] = as.character(clade)
    mbProb[index] = mbTable$V2[i]
    foundMatch = FALSE
    for (j in 1:dim(bistroTable)[1]) {
      bistroclade = bistroTable$V1[j]
      if (clade == bistroclade) {
        bistroProb[index] = bistroTable$V2[j]
        index = index+1
        foundMatch = TRUE
      }
    }
    if (!foundMatch) {
      bistroProb[index] = 0
      index = index+1
    }
  }
}

combinedTable = data.frame(combinedClades, mbProb, bistroProb)

plot(ggplot() +
       geom_point(data=combinedTable, aes(x=combinedClades, y=mbProb), color='red') +
       geom_point(data=combinedTable, aes(x=combinedClades, y=bistroProb), color='blue') +
       labs(x = "Clade", y = "Probability", color = "Legend\n") +
       scale_color_manual(labels=c("Bistro", "MB"), values = c("blue", "red")) +  
       theme_bw() + 
       theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1)))
