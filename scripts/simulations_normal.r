## same as simulations.r for 4 taxa, but
## now using normal for the bl, and keeping the
## dependence from start (see ipad formulas)
## Claudia April 2016
## modified to save loglik separate from logw

library(ape)
source('branch-length_lik.r')
source('4taxa_functions.r')
library(ggplot2)
library(weights)
library(mvtnorm)

## ------------------
## Case (1,2)---3
## Here we want to compare the cov matrix from the NJ formulas
## and the covariance matrix from Information from likelihood
## Since the case (1,2)--3 is well behaved, we expect the lik covariance
## to be well captured by the covariance from NJ formulas

## todo: need to modify this
who="Case (1,2)---3"
d1x0=0.1
d2x0=0.1
d3x0=0.1
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
## simulate seq3
P = matrixExp(Q,d3x0)
seq3 = numeric(nsites)
for ( i in 1:nsites )
    seq3[i] = sample(nuc,size=1,prob=P[which(nuc==seqx[i]),])

seq1.dist = seqMatrix(seq1)
seq2.dist = seqMatrix(seq2)
seq3.dist = seqMatrix(seq3)

## gamma density
out12 = countsMatrix(seq1,seq2)
out13 = countsMatrix(seq1,seq3)
out23 = countsMatrix(seq2,seq3)

nreps = 1000
logwv = rep(0,nreps)
d1x = rep(0,nreps)
d2x = rep(0,nreps)
d3x = rep(0,nreps)
for(nr in 1:nreps){
    print(nr)
    ## first we want MLE and Info but jointly
    ## then we simulate jointly d1x,d2x,d3x, and everything stays the same
    ## keep the matrices to compare, and keep the other procedure to compare also
    jc12 = simulateBranchLength.jc(nsim=1,out12,eta=eta)
    jc13 = simulateBranchLength.jc(nsim=1,out13,eta=eta)
    jc23 = simulateBranchLength.jc(nsim=1,out23,eta=eta)

    t.lik12 = simulateBranchLength.lik(nsim=1, seq1.dist,seq2.dist,Q,t0=jc12$t,eta=eta)
    t.lik13 = simulateBranchLength.lik(nsim=1, seq1.dist,seq3.dist,Q,t0=jc13$t,eta=eta)
    t.lik23 = simulateBranchLength.lik(nsim=1, seq2.dist,seq3.dist,Q,t0=jc23$t,eta=eta)

    d12 = t.lik12$t
    d13 = t.lik13$t
    d23 = t.lik23$t

    d1x[nr] = (d12+d13-d23)/2
    d2x[nr] = (d12+d23-d13)/2
    d3x[nr] = (d13+d23-d12)/2

    if(d1x[nr]<0 || d2x[nr]<0 || d3x[nr]<0){
        print("negative bl")
    } else{
        P1 = matrixExp(Q,d1x[nr])
        P2 = matrixExp(Q,d2x[nr])
        P3 = matrixExp(Q,d3x[nr])
        suma = 0
        for(ns in 1:nsites){
            l1 = P1 %*% seq1.dist[,ns]
            l2 = P2 %*% seq2.dist[,ns]
            l3 = P3 %*% seq3.dist[,ns]
            suma = suma + log(sum(Q$p * l1 * l2 * l3))
        }
        logdens = (t.lik12$alpha-1)*log(d12)-t.lik12$beta*d12 + (t.lik13$alpha-1)*log(d13)-t.lik13$beta*d13 + (t.lik23$alpha-1)*log(d23)-t.lik23$beta*d23
        logwv[nr] = -10*(d1x[nr]+d2x[nr]+d3x[nr]) +suma - logdens
    }
}

data = data.frame(d1x,d2x,d3x,logwv)
head(data)
summary(data)
data[data$logwv==0,]
length(data[data$logwv==0,]$logwv)
data <- subset(data,logwv!=0)
my.logw = data$logwv - mean(data$logwv)
data$w = exp(my.logw)/sum(exp(my.logw))
data[data$w>0.01,]
hist(data$w)
save(data,file="data1m.Rda")

m.1x=weighted.mean(data$d1x,data$w)
m2.1x=weighted.mean(data$d1x^2,data$w)
v.1x=m2.1x-m.1x^2
m.1x
m.1x-2*sqrt(v.1x)
m.1x+2*sqrt(v.1x)
d1x0
weighted.quantile(data$d1x,data$w,probs=0.025)
weighted.quantile(data$d1x,data$w,probs=0.975)
plot(data$d1x,data$w, main="red=true, blue=weighted mean")
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")


m.2x=weighted.mean(data$d2x,data$w)
m2.2x=weighted.mean(data$d2x^2,data$w)
v.2x=m2.2x-m.2x^2
m.2x
m.2x-2*sqrt(v.2x)
m.2x+2*sqrt(v.2x)
d2x0
weighted.quantile(data$d2x,data$w,probs=0.025)
weighted.quantile(data$d2x,data$w,probs=0.975)
plot(data$d2x,data$w, main="red=true, blue=weighted mean")
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")


m.3x=weighted.mean(data$d3x,data$w)
m2.3x=weighted.mean(data$d3x^2,data$w)
v.3x=m2.3x-m.3x^2
m.3x
m.3x-2*sqrt(v.3x)
m.3x+2*sqrt(v.3x)
d3x0
weighted.quantile(data$d3x,data$w,probs=0.025)
weighted.quantile(data$d3x,data$w,probs=0.975)
plot(data$d3x,data$w, main="red=true, blue=weighted mean")
abline(v=d3x0, col="red")
abline(v=m.3x,col="blue")


## weighted histograms
wtd.hist(data$d1x,weight=data$w)
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")

wtd.hist(data$d2x,weight=data$w)
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")

wtd.hist(data$d3x,weight=data$w)
abline(v=d3x0, col="red")
abline(v=m.3x,col="blue")

## ---------------------------------------------------------------------------------------------------------------------------------
## now we want to see if things change when we sample them
## jointly
## here logdens1, logdens2 do not make sense because we are not using the
## simulated normal for d12,d13,d23,d14,d34
## we are simulating new normal for d1x,d2x,dxy,d3y,d4y
## conclusion: same problems, ~10/1000 weights
who="(1,2)---(3,4)"
## d1x0=0.11
## d2x0=0.078
## dxy0 = 0.03
## d3y0 = 0.091
## d4y0 = 0.098
d1x0=0.15
d2x0=0.15
dxy0 = 0.15
d3y0 = 0.15
d4y0 = 0.15
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

## simulate seq3
P = matrixExp(Q,d3y0)
seq3 = numeric(nsites)
for ( i in 1:nsites )
    seq3[i] = sample(nuc,size=1,prob=P[which(nuc==seqy[i]),])
## simulate seq4
P = matrixExp(Q,d4y0)
seq4 = numeric(nsites)
for ( i in 1:nsites )
    seq4[i] = sample(nuc,size=1,prob=P[which(nuc==seqy[i]),])


seq1.dist = seqMatrix(seq1)
seq2.dist = seqMatrix(seq2)
seq3.dist = seqMatrix(seq3)
seq4.dist = seqMatrix(seq4)

## gamma density
out12 = countsMatrix(seq1,seq2)
out13 = countsMatrix(seq1,seq3)
out14 = countsMatrix(seq1,seq4)
out23 = countsMatrix(seq2,seq3)
out34 = countsMatrix(seq3,seq4)

nreps = 1000
logwv3 = rep(0,nreps)
logl = rep(0,nreps)
logdens3 = rep(0,nreps) #dep normal
d1x=rep(0,nreps)
d2x=rep(0,nreps)
d3y=rep(0,nreps)
d4y=rep(0,nreps)
dxy=rep(0,nreps)

for(nr in 1:nreps){
    print(nr)
    jc12 = simulateBranchLength.jc(nsim=1,out12,eta=eta)
    jc13 = simulateBranchLength.jc(nsim=1,out13,eta=eta)
    jc14 = simulateBranchLength.jc(nsim=1,out14,eta=eta)
    jc23 = simulateBranchLength.jc(nsim=1,out23,eta=eta)
    jc34 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
        ## starting point for d3x,d4x
    t0=(max(c(jc12$t,jc13$t,jc23$t))+min(c(jc12$t,jc13$t,jc23$t)))/2

    t.lik12 = simulateBranchLength.norm(nsim=1, seq1.dist,seq2.dist,Q,t0=jc12$t,eta=eta)
    t.lik13 = simulateBranchLength.norm(nsim=1, seq1.dist,seq3.dist,Q,t0=jc13$t,eta=eta)
    t.lik14 = simulateBranchLength.norm(nsim=1, seq1.dist,seq4.dist,Q,t0=jc14$t,eta=eta)
    t.lik23 = simulateBranchLength.norm(nsim=1, seq2.dist,seq3.dist,Q,t0=jc23$t,eta=eta)
    t.lik34 = simulateBranchLength.norm(nsim=1, seq3.dist,seq4.dist,Q,t0=jc34$t,eta=eta)

    mu.d1x = 0.5*(t.lik12$mu+t.lik13$mu-t.lik23$mu)
    mu.d2x = 0.5*(t.lik12$mu-t.lik13$mu+t.lik23$mu)
    mu.dxy = 0.5*(-t.lik12$mu+t.lik23$mu+t.lik14$mu-t.lik34$mu)
    mu.d3y = 0.5*(t.lik13$mu-t.lik14$mu+t.lik34$mu)
    mu.d4y = 0.5*(-t.lik13$mu+t.lik14$mu+t.lik34$mu)

    A = matrix(c(1/2,1/2,-1/2,0,0,1/2,-1/2,0,1/2,-1/2,-1/2,1/2,1/2,0,0,0,0,1/2,-1/2,1/2,0,0,-1/2,1/2,1/2),ncol=5)
    S = diag(c(t.lik12$sigma^2, t.lik13$sigma^2, t.lik23$sigma^2, t.lik14$sigma^2, t.lik34$sigma^2))
    newS = A %*% S %*% t(A)
    bl = rmvnorm(n=1, mean=c(mu.d1x,mu.d2x,mu.dxy,mu.d3y,mu.d4y), sigma = newS)

    d1x[nr] = bl[1]
    d2x[nr] = bl[2]
    dxy[nr] = bl[3]
    d3y[nr] = bl[4]
    d4y[nr] = bl[5]

    if(d1x[nr]<0 || d2x[nr]<0 || d3y[nr]<0 || d4y[nr]<0 || dxy[nr]<0){
        print("negative bl")
    } else{
        print("all positive")
        print(paste(d1x[nr],d2x[nr], dxy[nr], d3y[nr], d4y[nr]))
        logl[nr] = gtr.log.lik.all(d1x[nr],d2x[nr],dxy[nr],d3y[nr],d4y[nr],seq1.dist, seq2.dist, seq3.dist, seq4.dist, Q)
        logdens3[nr] = logJointDensity.multinorm(d1x[nr], d2x[nr], dxy[nr], d3y[nr], d4y[nr], t.lik12,t.lik13,t.lik23,t.lik14,t.lik34) #from multinorm
        logprior  = 0 #= logPriorExpDist(d1x[nr], d2x[nr], d3y[nr], d4y[nr], dxy[nr], m=0.1)
        logwv3[nr] = logprior +logl[nr] - logdens3[nr]
    }
}

data = data.frame(d1x,d2x,d3y,d4y,dxy,logwv3, logl, logdens3)
head(data)
summary(data)
data[data$logwv3==0,]
length(data[data$logwv3==0,]$logwv3)
data <- subset(data,logwv3!=0)
my.logw3 = data$logwv3 - mean(data$logwv3)
data$w3 = exp(my.logw3)/sum(exp(my.logw3))
data[data$w3>0.01,]
length(data[data$w3>0.01,]$w3)
hist(data$w3)
summary(data)
##save(data,file="data_simulations.Rda")

m.1x=weighted.mean(data$d1x,data$w)
m2.1x=weighted.mean(data$d1x^2,data$w)
v.1x=m2.1x-m.1x^2
m.1x
m.1x-2*sqrt(v.1x)
m.1x+2*sqrt(v.1x)
d1x0
weighted.quantile(data$d1x,data$w,probs=0.025)
weighted.quantile(data$d1x,data$w,probs=0.975)
plot(data$d1x,data$w, main="red=true, blue=weighted mean")
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")


m.2x=weighted.mean(data$d2x,data$w)
m2.2x=weighted.mean(data$d2x^2,data$w)
v.2x=m2.2x-m.2x^2
m.2x
m.2x-2*sqrt(v.2x)
m.2x+2*sqrt(v.2x)
d2x0
weighted.quantile(data$d2x,data$w,probs=0.025)
weighted.quantile(data$d2x,data$w,probs=0.975)
plot(data$d2x,data$w, main="red=true, blue=weighted mean")
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")


m.3y=weighted.mean(data$d3y,data$w)
m2.3y=weighted.mean(data$d3y^2,data$w)
v.3y=m2.3y-m.3y^2
m.3y
m.3y-2*sqrt(v.3y)
m.3y+2*sqrt(v.3y)
d3y0
weighted.quantile(data$d3y,data$w,probs=0.025)
weighted.quantile(data$d3y,data$w,probs=0.975)
plot(data$d3y,data$w, main="red=true, blue=weighted mean")
abline(v=d3y0, col="red")
abline(v=m.3y,col="blue")

m.4y=weighted.mean(data$d4y,data$w)
m2.4y=weighted.mean(data$d4y^2,data$w)
v.4y=m2.4y-m.4y^2
m.4y
m.4y-2*sqrt(v.4y)
m.4y+2*sqrt(v.4y)
d4y0
weighted.quantile(data$d4y,data$w,probs=0.025)
weighted.quantile(data$d4y,data$w,probs=0.975)
plot(data$d4y,data$w, main="red=true, blue=weighted mean")
abline(v=d4y0, col="red")
abline(v=m.4y,col="blue")


m.xy=weighted.mean(data$dxy,data$w)
m2.xy=weighted.mean(data$dxy^2,data$w)
v.xy=m2.xy-m.xy^2
m.xy
m.xy-2*sqrt(v.xy)
m.xy+2*sqrt(v.xy)
dxy0
weighted.quantile(data$dxy,data$w,probs=0.025)
weighted.quantile(data$dxy,data$w,probs=0.975)
plot(data$dxy,data$w, main="red=true, blue=weighted mean")
abline(v=dxy0, col="red")
abline(v=m.xy,col="blue")


## weighted histograms
wtd.hist(data$d1x,weight=data$w)
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")

wtd.hist(data$d2x,weight=data$w)
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")

wtd.hist(data$d3y,weight=data$w)
abline(v=d3y0, col="red")
abline(v=m.3y,col="blue")

wtd.hist(data$d4y,weight=data$w)
abline(v=d4y0, col="red")
abline(v=m.4y,col="blue")

wtd.hist(data$dxy,weight=data$w)
abline(v=dxy0, col="red")
abline(v=m.xy,col="blue")

## real histograms for nsites=150000 case
hist(data$d1x)
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")

hist(data$d2x)
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")

hist(data$d3y)
abline(v=d3y0, col="red")
abline(v=m.3y,col="blue")

hist(data$d4y)
abline(v=d4y0, col="red")
abline(v=m.4y,col="blue")

hist(data$dxy)
abline(v=dxy0, col="red")
abline(v=m.xy,col="blue")


## how do weights behave??
## comparing three densities: normal without constant, normal with constant, dep normal
## all the three weights are identical (as they should)
## and we still have few weights with all the weight
who="(1,2)---(3,4)"
## d1x0=0.11
## d2x0=0.078
## dxy0 = 0.03
## d3y0 = 0.091
## d4y0 = 0.098
d1x0=0.1
d2x0=0.1
dxy0 = 0.1
d3y0 = 0.1
d4y0 = 0.1
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

## simulate seq3
P = matrixExp(Q,d3y0)
seq3 = numeric(nsites)
for ( i in 1:nsites )
    seq3[i] = sample(nuc,size=1,prob=P[which(nuc==seqy[i]),])
## simulate seq4
P = matrixExp(Q,d4y0)
seq4 = numeric(nsites)
for ( i in 1:nsites )
    seq4[i] = sample(nuc,size=1,prob=P[which(nuc==seqy[i]),])


seq1.dist = seqMatrix(seq1)
seq2.dist = seqMatrix(seq2)
seq3.dist = seqMatrix(seq3)
seq4.dist = seqMatrix(seq4)

## gamma density
out12 = countsMatrix(seq1,seq2)
out13 = countsMatrix(seq1,seq3)
out14 = countsMatrix(seq1,seq4)
out23 = countsMatrix(seq2,seq3)
out34 = countsMatrix(seq3,seq4)

nreps = 1000
logwv1 = rep(0,nreps)
logwv2 = rep(0,nreps)
logwv3 = rep(0,nreps)
logl = rep(0,nreps)
logdens1 = rep(0,nreps) #indep normal without constant
logdens2 = rep(0,nreps) #indep normal with constant
logdens3 = rep(0,nreps) #dep normal
d1x=rep(0,nreps)
d2x=rep(0,nreps)
d3y=rep(0,nreps)
d4y=rep(0,nreps)
dxy=rep(0,nreps)

for(nr in 1:nreps){
    print(nr)
    jc12 = simulateBranchLength.jc(nsim=1,out12,eta=eta)
    jc13 = simulateBranchLength.jc(nsim=1,out13,eta=eta)
    jc14 = simulateBranchLength.jc(nsim=1,out14,eta=eta)
    jc23 = simulateBranchLength.jc(nsim=1,out23,eta=eta)
    jc34 = simulateBranchLength.jc(nsim=1,out34,eta=eta)
        ## starting point for d3x,d4x
    t0=(max(c(jc12$t,jc13$t,jc23$t))+min(c(jc12$t,jc13$t,jc23$t)))/2

    t.lik12 = simulateBranchLength.norm(nsim=1, seq1.dist,seq2.dist,Q,t0=jc12$t,eta=eta)
    t.lik13 = simulateBranchLength.norm(nsim=1, seq1.dist,seq3.dist,Q,t0=jc13$t,eta=eta)
    t.lik14 = simulateBranchLength.norm(nsim=1, seq1.dist,seq4.dist,Q,t0=jc14$t,eta=eta)
    t.lik23 = simulateBranchLength.norm(nsim=1, seq2.dist,seq3.dist,Q,t0=jc23$t,eta=eta)
    t.lik34 = simulateBranchLength.norm(nsim=1, seq3.dist,seq4.dist,Q,t0=jc34$t,eta=eta)

    d12 = t.lik12$t
    d13 = t.lik13$t
    d14 = t.lik14$t
    d23 = t.lik23$t
    d34 = t.lik34$t

    d1x[nr] = (d12+d13-d23)/2
    d2x[nr] = (d12+d23-d13)/2
    dxy[nr] = (d14-d34-d12+d23)/2
    d3y[nr] = (d13-d14+d34)/2
    d4y[nr] = (d14-d13+d34)/2

    if(d1x[nr]<0 || d2x[nr]<0 || d3y[nr]<0 || d4y[nr]<0 || dxy[nr]<0){
        print("negative bl")
    } else{
        print("all positive")
        print(paste(d1x[nr],d2x[nr], dxy[nr], d3y[nr], d4y[nr]))
        logl[nr] = gtr.log.lik.all(d1x[nr],d2x[nr],dxy[nr],d3y[nr],d4y[nr],seq1.dist, seq2.dist, seq3.dist, seq4.dist, Q)
        logdens = logJointDensity.norm(t.lik12,t.lik13,t.lik23,t.lik14,t.lik34)
        logdens3[nr] = logJointDensity.multinorm(d1x[nr], d2x[nr], dxy[nr], d3y[nr], d4y[nr], t.lik12,t.lik13,t.lik23,t.lik14,t.lik34) #from multinorm
        logdens1[nr] = logdens$logd1 #no constant
        logdens2[nr] = logdens$logd2 #from dnorm
        logprior  = 0 #= logPriorExpDist(d1x[nr], d2x[nr], d3y[nr], d4y[nr], dxy[nr], m=0.1)
        logwv1[nr] = logprior +logl[nr] - logdens1[nr]
        logwv2[nr] = logprior +logl[nr] - logdens2[nr]
        logwv3[nr] = logprior +logl[nr] - logdens3[nr]
    }
}

data = data.frame(d1x,d2x,d3y,d4y,dxy,logwv1, logwv2, logwv3, logl, logdens1, logdens2, logdens3)
head(data)
summary(data)
data[data$logwv1==0,]
length(data[data$logwv1==0,]$logwv1)
data <- subset(data,logwv1!=0)
my.logw1 = data$logwv1 - mean(data$logwv1)
my.logw2 = data$logwv2 - mean(data$logwv2)
my.logw3 = data$logwv3 - mean(data$logwv3)
data$w1 = exp(my.logw1)/sum(exp(my.logw1))
data$w2 = exp(my.logw2)/sum(exp(my.logw2))
data$w3 = exp(my.logw3)/sum(exp(my.logw3))
data[data$w1>0.01,]
data[data$w2>0.01,]
data[data$w3>0.01,]
length(data[data$w1>0.01,]$w1)
length(data[data$w2>0.01,]$w2)
length(data[data$w3>0.01,]$w3)
hist(data$w1)
hist(data$w2)
hist(data$w3)
##save(data,file="data_simulations.Rda")

m.1x=weighted.mean(data$d1x,data$w)
m2.1x=weighted.mean(data$d1x^2,data$w)
v.1x=m2.1x-m.1x^2
m.1x
m.1x-2*sqrt(v.1x)
m.1x+2*sqrt(v.1x)
d1x0
weighted.quantile(data$d1x,data$w,probs=0.025)
weighted.quantile(data$d1x,data$w,probs=0.975)
plot(data$d1x,data$w, main="red=true, blue=weighted mean")
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")


m.2x=weighted.mean(data$d2x,data$w)
m2.2x=weighted.mean(data$d2x^2,data$w)
v.2x=m2.2x-m.2x^2
m.2x
m.2x-2*sqrt(v.2x)
m.2x+2*sqrt(v.2x)
d2x0
weighted.quantile(data$d2x,data$w,probs=0.025)
weighted.quantile(data$d2x,data$w,probs=0.975)
plot(data$d2x,data$w, main="red=true, blue=weighted mean")
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")


m.3y=weighted.mean(data$d3y,data$w)
m2.3y=weighted.mean(data$d3y^2,data$w)
v.3y=m2.3y-m.3y^2
m.3y
m.3y-2*sqrt(v.3y)
m.3y+2*sqrt(v.3y)
d3y0
weighted.quantile(data$d3y,data$w,probs=0.025)
weighted.quantile(data$d3y,data$w,probs=0.975)
plot(data$d3y,data$w, main="red=true, blue=weighted mean")
abline(v=d3y0, col="red")
abline(v=m.3y,col="blue")

m.4y=weighted.mean(data$d4y,data$w)
m2.4y=weighted.mean(data$d4y^2,data$w)
v.4y=m2.4y-m.4y^2
m.4y
m.4y-2*sqrt(v.4y)
m.4y+2*sqrt(v.4y)
d4y0
weighted.quantile(data$d4y,data$w,probs=0.025)
weighted.quantile(data$d4y,data$w,probs=0.975)
plot(data$d4y,data$w, main="red=true, blue=weighted mean")
abline(v=d4y0, col="red")
abline(v=m.4y,col="blue")


m.xy=weighted.mean(data$dxy,data$w)
m2.xy=weighted.mean(data$dxy^2,data$w)
v.xy=m2.xy-m.xy^2
m.xy
m.xy-2*sqrt(v.xy)
m.xy+2*sqrt(v.xy)
dxy0
weighted.quantile(data$dxy,data$w,probs=0.025)
weighted.quantile(data$dxy,data$w,probs=0.975)
plot(data$dxy,data$w, main="red=true, blue=weighted mean")
abline(v=dxy0, col="red")
abline(v=m.xy,col="blue")


## weighted histograms
wtd.hist(data$d1x,weight=data$w)
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")

wtd.hist(data$d2x,weight=data$w)
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")

wtd.hist(data$d3y,weight=data$w)
abline(v=d3y0, col="red")
abline(v=m.3y,col="blue")

wtd.hist(data$d4y,weight=data$w)
abline(v=d4y0, col="red")
abline(v=m.4y,col="blue")

wtd.hist(data$dxy,weight=data$w)
abline(v=dxy0, col="red")
abline(v=m.xy,col="blue")

## real histograms for nsites=150000 case
hist(data$d1x)
abline(v=d1x0, col="red")
abline(v=m.1x,col="blue")

hist(data$d2x)
abline(v=d2x0, col="red")
abline(v=m.2x,col="blue")

hist(data$d3y)
abline(v=d3y0, col="red")
abline(v=m.3y,col="blue")

hist(data$d4y)
abline(v=d4y0, col="red")
abline(v=m.4y,col="blue")

hist(data$dxy)
abline(v=dxy0, col="red")
abline(v=m.xy,col="blue")
