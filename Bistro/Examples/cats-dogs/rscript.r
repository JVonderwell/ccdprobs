library(ape)
source("../../Scripts/readBistro.r")
stem = "dist2"
bistro = readBistro(stem)
data = readDataSort(stem)
keep = which(bistro$tree=="(1,2,((3,((4,5),6)),(((((7,8),9),10),11),12)));")
tre.bistro = data$V1[keep]
N.bistro = length(tre.bistro)
tree = read.tree(text="(1,2,((3,((4,5),6)),(((((7,8),9),10),11),12)));")
## get number of edges
m.bistro = matrix(0,N.bistro,length(tree$edge[,1]))
colnames(m.bistro) = paste("b",tree$edge[,2],tree$edge[,1],sep=".")
for ( i in 1:N.bistro )
{
    tree = read.tree(text=as.character(tre.bistro[i]))
    m.bistro[i,] = tree$edge.length
}

tre = read.table("mcmc2.tre")
n = nrow(tre)
burn = n/11
head(tre)
tre.mb = as.character(tre[-(1:burn),])
N.mb = length(tre.mb) ### 1000 now!!!

tree = read.tree(text=tre.mb[1])
## get number of edges
m.mb = matrix(0,N.mb,length(tree$edge.length))
colnames(m.mb) = paste("b",tree$edge[,2],tree$edge[,1],sep=".")

for ( i in 1:N.mb )
{
    tree = read.tree(text=tre.mb[i])
    m.mb[i,] = tree$edge.length
}
