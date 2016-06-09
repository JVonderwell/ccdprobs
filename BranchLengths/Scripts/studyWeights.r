## R script to study the weights in logw.txt
## after ./bl ....
## Claudia May 2016
## Modified by Bret on June 1, 2016
## Modified by Claudia to save info on table for simulation study (6/7/16)
## run: R CMD BATCH studyWeights.r ntax rep time seed
## will append to weights.txt for all replicates

args = commandArgs(trailingOnly=TRUE)
if(length(args) == 0){
    ntax = 0
    rep = 0
    time = 0
    seed = 0
}else{
    ntax = strtoi(args[1])
    rep = strtoi(args[2])
    time = strtoi(args[3])
    seed = strtoi(args[4])
}


dat = read.csv("logw.txt",header=FALSE)
logweight = dat[,ncol(dat)]
logw = logweight - max(logweight)
w = exp(logw) / sum(exp(logw))
m = mean(w)
mi = min(w)
ma = max(w)
nbig = length(w[w>0.01])
nrep = length(w)
ess = 1/sum(w^2)
essp = ess/nrep

write.table(data.frame(ntax,rep,time,seed,mi,m,ma,nbig,nrep,ess,essp), file="weights.txt", append=TRUE, row.names=FALSE, col.names=FALSE, sep=",")
