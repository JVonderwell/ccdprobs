## to repeat the simulations_normal.r file but
## now for 5 taxa and the case when two sums are known
## Claudia April 2016

library(ape)
source('branch-length_lik.r')
source('4taxa_functions.r')
library(ggplot2)
library(weights)
library(mvtnorm)

## ------------------
## Case (1,2)x---(3,4)z---y---5
d1x0 = 0.1
d2x0 = 0.1
dxy0 = 0.1
d3z0 = 0.1
d4z0 = 0.1
dyz0 = 0.1
d5y0 = 0.1
eta = 0.5
nsites=1500
nuc <- c('a','c','g','t')
Q = randomQ(4,rescale=TRUE)
r=Q$r
p=Q$p
## simulate seqx
seqx = sample(nuc,size=nsites,prob=Q$p,replace=TRUE)

## simulate seq1
P = matrixExp(Q,d1x0)
seq1 = numeric(nsites)
for ( i in 1:nsites )
    seq1[i] = sample(nuc,size=1,prob=P[which(nuc==seqx[i]),])
## simulate seq2
P = matrixExp(Q,d2x0)
seq2 = numeric(nsites)
for ( i in 1:nsites )
    seq2[i] = sample(nuc,size=1,prob=P[which(nuc==seqx[i]),])

## simulate seqy
P = matrixExp(Q,dxy0)
seqy = numeric(nsites)
for ( i in 1:nsites )
    seqy[i] = sample(nuc,size=1,prob=P[which(nuc==seqx[i]),])

## simulate seqz
P = matrixExp(Q,dyz0)
seqz = numeric(nsites)
for ( i in 1:nsites )
    seqz[i] = sample(nuc,size=1,prob=P[which(nuc==seqy[i]),])

## simulate seq5
P = matrixExp(Q,d5y0)
seq5 = numeric(nsites)
for ( i in 1:nsites )
    seq5[i] = sample(nuc,size=1,prob=P[which(nuc==seqy[i]),])

## simulate seq3
P = matrixExp(Q,d3z0)
seq3 = numeric(nsites)
for ( i in 1:nsites )
    seq3[i] = sample(nuc,size=1,prob=P[which(nuc==seqz[i]),])
## simulate seq4
P = matrixExp(Q,d4z0)
seq4 = numeric(nsites)
for ( i in 1:nsites )
    seq4[i] = sample(nuc,size=1,prob=P[which(nuc==seqz[i]),])


seq1.dist = seqMatrix(seq1)
seq2.dist = seqMatrix(seq2)
seq3.dist = seqMatrix(seq3)
seq4.dist = seqMatrix(seq4)
seq5.dist = seqMatrix(seq5)

## gamma density
out12 = countsMatrix(seq1,seq2)
out13 = countsMatrix(seq1,seq3)
out23 = countsMatrix(seq2,seq3)
out34 = countsMatrix(seq3,seq4)
out35 = countsMatrix(seq3,seq5)
out45 = countsMatrix(seq4,seq5)

nreps = 1000

logwv.cond = rep(0,nreps)
logl.cond = rep(0,nreps)
logdens.cond = rep(0,nreps)
d1x.cond=rep(0,nreps)
d2x.cond=rep(0,nreps)
d3x.cond=rep(0,nreps)
d3z.cond=rep(0,nreps)
d4z.cond=rep(0,nreps)
d5z.cond=rep(0,nreps)
dxy.cond=rep(0,nreps)
dyz.cond=rep(0,nreps)
d5y.cond=rep(0,nreps)
mean1.cond <- vector("list",nreps)
mean2.cond <- vector("list",nreps)
mean3.cond <- vector("list",nreps)

logwv.cond2 = rep(0,nreps)
logl.cond2 = rep(0,nreps)
logdens.cond2 = rep(0,nreps)
d1x.cond2=rep(0,nreps)
d2x.cond2=rep(0,nreps)
d3x.cond2=rep(0,nreps)
d3z.cond2=rep(0,nreps)
d4z.cond2=rep(0,nreps)
dxz.cond2=rep(0,nreps)
dxy.cond2=rep(0,nreps)
dyz.cond2=rep(0,nreps)
d5y.cond2=rep(0,nreps)
mean1.cond2 <- vector("list",nreps)
mean2.cond2 <- vector("list",nreps)
mean3.cond2 <- vector("list",nreps)

for(nr in 1:nreps){
    print(nr)
    ## ----------------------- conditional: 2 sums ------------------------------------------
    ## simulate d1x,d2x,d3x
    jc12 = simulateBranchLength.jc(nsim=1,out12,eta=eta)
    jc13 = simulateBranchLength.jc(nsim=1,out13,eta=eta)
    jc23 = simulateBranchLength.jc(nsim=1,out23,eta=eta)
    t.lik12 = simulateBranchLength.norm(nsim=1, seq1.dist,seq2.dist,Q,t0=jc12$t,eta=eta)
    t.lik13 = simulateBranchLength.norm(nsim=1, seq1.dist,seq3.dist,Q,t0=jc13$t,eta=eta)
    t.lik23 = simulateBranchLength.norm(nsim=1, seq2.dist,seq3.dist,Q,t0=jc23$t,eta=eta)
    d12 = t.lik12$t
    d13 = t.lik13$t
    d23 = t.lik23$t
    d1x.t0 = (d12+d13-d23)/2
    d2x.t0 = (d12+d23-d13)/2
    d3x.t0 = (d13+d23-d12)/2

    d = simulateBranchLength.multinorm(nsim=1,seq1.dist, seq2.dist, seq3.dist,Q,t0=c(d1x.t0, d2x.t0, d3x.t0))
    d1x.cond[nr] = d$t[1]
    d2x.cond[nr] = d$t[2]
    d3x.cond[nr] = d$t[3]
    mean1.cond[[nr]] = d$mu

    ## simulate d3z,d4z,d5z (question: do we need to condition here on d3x? I don't think so)
    jc34 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
    jc35 = simulateBranchLength.jc(nsim=1,out35,eta=eta)
    jc45 = simulateBranchLength.jc(nsim=1,out45,eta=eta)
    t.lik34 = simulateBranchLength.norm(nsim=1, seq3.dist,seq4.dist,Q,t0=jc34$t,eta=eta)
    t.lik35 = simulateBranchLength.norm(nsim=1, seq3.dist,seq5.dist,Q,t0=jc35$t,eta=eta)
    t.lik45 = simulateBranchLength.norm(nsim=1, seq4.dist,seq5.dist,Q,t0=jc45$t,eta=eta)
    d34 = t.lik34$t
    d35 = t.lik35$t
    d45 = t.lik45$t
    d3z.t0 = (d34+d35-d45)/2
    d4z.t0 = (d34+d45-d35)/2
    d5z.t0 = (d35+d45-d34)/2

    d2 = simulateBranchLength.multinorm(nsim=1,seq3.dist, seq4.dist, seq5.dist,Q,t0=c(d3z.t0, d4z.t0, d5z.t0))
    d3z.cond[nr] = d2$t[1]
    d4z.cond[nr] = d2$t[2]
    d5z.cond[nr] = d2$t[3]
    mean2.cond[[nr]] = d2$mu

    ## simulate dyz
    seqx.dist = sequenceDist(d1x.cond[nr], d2x.cond[nr] ,seq1.dist, seq2.dist, Q)
    seqz.dist = sequenceDist(d3z.cond[nr], d4z.cond[nr] ,seq3.dist, seq4.dist, Q)

    dyz.t0 = dxy.cond[nr] # fixit: using dxy as starting point for yz because I know they are close, but in general?

    d3 = simulateBranchLength.conditionalNorm(nsim=1,seqx.dist, seqz.dist, seq5.dist,Q,t0=dyz.t0,d3x.cond[nr]-d3z.cond[nr], d5z.cond[nr]) #s1=d3x-d3z, s2=d5z
    dyz.cond[nr] = d3$t
    mean3.cond[[nr]] = d3$mu

    dxy.cond[nr] = d3x.cond[nr]-d3z.cond[nr]-dyz.cond[nr]
    d5y.cond[nr] = d5z.cond[nr] - dyz.cond[nr]


    if(d1x.cond[nr]<0 || d2x.cond[nr]<0 || d3z.cond[nr]<0 || d4z.cond[nr]<0 || dxy.cond[nr]<0 || dyz.cond[nr]<0 || d5y.cond[nr]<0){
        print("negative bl")
    } else{
        print("all positive")
        print(c(d1x.cond[nr], d2x.cond[nr], d3z.cond[nr], d4z.cond[nr], dxy.cond[nr], dyz.cond[nr], d5y.cond[nr]))
        logl.cond[nr] = gtr.log.lik.all.5taxa(d1x.cond[nr],d2x.cond[nr],dxy.cond[nr],dyz.cond[nr],d3z.cond[nr],d4z.cond[nr],d5y.cond[nr], seq1.dist, seq2.dist, seq3.dist, seq4.dist, seq5.dist, Q)
        logdens.cond[nr] = log(dmvnorm(d$t,mean=d$mu, sigma=d$sigma))+log(dmvnorm(d2$t,mean=d2$mu,sigma=d2$sigma))+log(dnorm(x=d3$t,mean=d3$mu,sd=sqrt(d3$sigma)))
        logprior = logPriorExpDist.5taxa(d1x.cond[nr],d2x.cond[nr],dxy.cond[nr],dyz.cond[nr],d3z.cond[nr],d4z.cond[nr],d5y.cond[nr],m=0.1)
        logwv.cond[nr] = logprior + logl.cond[nr] - logdens.cond[nr]
    }

    ## ----------------------- conditional: 1 sum each time ------------------------------------------
    ## simulate d1x,d2x,d3x
    jc12 = simulateBranchLength.jc(nsim=1,out12,eta=eta)
    jc13 = simulateBranchLength.jc(nsim=1,out13,eta=eta)
    jc23 = simulateBranchLength.jc(nsim=1,out23,eta=eta)
    t.lik12 = simulateBranchLength.norm(nsim=1, seq1.dist,seq2.dist,Q,t0=jc12$t,eta=eta)
    t.lik13 = simulateBranchLength.norm(nsim=1, seq1.dist,seq3.dist,Q,t0=jc13$t,eta=eta)
    t.lik23 = simulateBranchLength.norm(nsim=1, seq2.dist,seq3.dist,Q,t0=jc23$t,eta=eta)
    d12 = t.lik12$t
    d13 = t.lik13$t
    d23 = t.lik23$t
    d1x.t0 = (d12+d13-d23)/2
    d2x.t0 = (d12+d23-d13)/2
    d3x.t0 = (d13+d23-d12)/2

    d = simulateBranchLength.multinorm(nsim=1,seq1.dist, seq2.dist, seq3.dist,Q,t0=c(d1x.t0, d2x.t0, d3x.t0))
    d1x.cond2[nr] = d$t[1]
    d2x.cond2[nr] = d$t[2]
    d3x.cond2[nr] = d$t[3]
    mean1.cond2[[nr]] = d$mu

    ## simulate d3z,d4z,dxz
    seqx.dist = sequenceDist(d1x.cond2[nr], d2x.cond2[nr] ,seq1.dist, seq2.dist, Q)

    jcx3 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
    jcx4 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
    jc34 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
    t.likx3 = simulateBranchLength.norm(nsim=1, seqx.dist,seq3.dist,Q,t0=jcx3$t,eta=eta)
    t.likx4 = simulateBranchLength.norm(nsim=1, seqx.dist,seq4.dist,Q,t0=jcx4$t,eta=eta)
    t.lik34 = simulateBranchLength.norm(nsim=1, seq3.dist,seq4.dist,Q,t0=jc34$t,eta=eta)
    d3x = t.likx3$t
    d4x = t.likx4$t
    d34 = t.lik34$t
    dxz.t0 = (d3x+d4x-d34)/2
    d3z.t0 = (d34+d3x-d4x)/2
    d4z.t0 = (d34+d4x-d3x)/2

    d2 = simulateBranchLength.conditionalMultinorm(nsim=1,seqx.dist, seq3.dist, seq4.dist,Q,t0=c(dxz.t0, d4z.t0),d3x.cond2[nr])
    dxz.cond2[nr] = d2$t[1]
    d4z.cond2[nr] = d2$t[2]
    d3z.cond2[nr] = d3x.cond2[nr] - dxz.cond2[nr]
    mean2.cond2[[nr]] = d2$mu

    ## simulate dxy,dyz,d5y
    seqz.dist = sequenceDist(d3z.cond2[nr], d4z.cond2[nr] ,seq3.dist, seq4.dist, Q)

    jcx5 = simulateBranchLength.jc(nsim=1,out34,eta=eta) #only works because we know they are similar, but in general?
    jcz5 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
    jcxz = simulateBranchLength.jc(nsim=1,out34,eta=eta)
    t.likx5 = simulateBranchLength.norm(nsim=1, seqx.dist,seq5.dist,Q,t0=jcx5$t,eta=eta)
    t.likz5 = simulateBranchLength.norm(nsim=1, seqz.dist,seq5.dist,Q,t0=jcz5$t,eta=eta)
    t.likxz = simulateBranchLength.norm(nsim=1, seqx.dist,seqz.dist,Q,t0=jcxz$t,eta=eta)
    d5x = t.likx5$t
    d5z = t.likz5$t
    dxz = t.likxz$t
    dxy.t0 = (d5x+dxz-d5z)/2
    dyz.t0 = (d5z+dxz-d5x)/2
    d5y.t0 = (d5z+d5x-dxz)/2

    d3 = simulateBranchLength.conditionalMultinorm(nsim=1,seqx.dist, seqz.dist, seq5.dist,Q,t0=c(dxy.t0, d5y.t0),dxz.cond2[nr])
    dxy.cond2[nr] = d3$t[1]
    d5y.cond2[nr] = d3$t[2]
    dyz.cond2[nr] = dxz.cond2[nr] - dxy.cond2[nr]
    mean3.cond2[[nr]] = d3$mu

    if(d1x.cond2[nr]<0 || d2x.cond2[nr]<0 || d3z.cond2[nr]<0 || d4z.cond2[nr]<0 || dxy.cond2[nr]<0 || dyz.cond2[nr]<0 || d5y.cond2[nr]<0){
        print("negative bl")
    } else{
        print("all positive")
        print(c(d1x.cond2[nr], d2x.cond2[nr], d3z.cond2[nr], d4z.cond2[nr], dxy.cond2[nr], dyz.cond2[nr], d5y.cond2[nr]))
        logl.cond2[nr] = gtr.log.lik.all.5taxa(d1x.cond2[nr],d2x.cond2[nr],dxy.cond2[nr],dyz.cond2[nr],d3z.cond2[nr],d4z.cond2[nr],d5y.cond2[nr], seq1.dist, seq2.dist, seq3.dist, seq4.dist, seq5.dist, Q)
        logdens.cond2[nr] = log(dmvnorm(d$t,mean=d$mu, sigma=d$sigma))+log(dmvnorm(d2$t,mean=d2$mu,sigma=d2$sigma))+log(dmvnorm(d3$t,mean=d3$mu,sigma=sqrt(d3$sigma)))
        logprior = logPriorExpDist.5taxa(d1x.cond2[nr],d2x.cond2[nr],dxy.cond2[nr],dyz.cond2[nr],d3z.cond2[nr],d4z.cond2[nr],d5y.cond2[nr],m=0.1)
        logwv.cond2[nr] = logprior + logl.cond2[nr] - logdens.cond2[nr]
    }
}

data = data.frame(d1x.cond,d2x.cond,d3x.cond,d3z.cond,d4z.cond,d5z.cond,dxy.cond,dyz.cond,d5y.cond,logwv.cond, logl.cond, logdens.cond,
    d1x.cond2,d2x.cond2,d3x.cond2,d3z.cond2,d4z.cond2,dxz.cond2,dxy.cond2,dyz.cond2,d5y.cond2,logwv.cond2, logl.cond2, logdens.cond2)
head(data)
summary(data)
data[data$logwv.cond==0,]
data[data$logwv.cond2==0,]
data <- subset(data,logwv.cond!=0)

my.logw.cond = data$logwv.cond - mean(data$logwv.cond)
data$w.cond = exp(my.logw.cond)/sum(exp(my.logw.cond))
data[data$w.cond>0.01,]
length(data[data$w.cond>0.01,]$w.cond)
hist(data$w.cond)
plot(1:length(data$w.cond),cumsum(rev(sort(data$w.cond))))

my.logw.cond2 = data$logwv.cond2 - mean(data$logwv.cond2)
data$w.cond2 = exp(my.logw.cond2)/sum(exp(my.logw.cond2))
data[data$w.cond2>0.01,]
length(data[data$w.cond2>0.01,]$w.cond2)
hist(data$w.cond2)
plot(1:length(data$w.cond2),cumsum(rev(sort(data$w.cond2))))

## effective sample size:
(1/sum(data$w.cond^2))/nreps
(1/sum(data$w.cond2^2))/nreps

save(data,file="data_5taxa.Rda")
load("data_5taxa.Rda")
