rm(list=ls(all = TRUE))
library(bpcp)

data <- read.csv("ctDNAfig2.csv")
data2 <- data[data$Cohort1upfrontresection2n == 2,]
time <- data2$WHRFS
status <- data2$WHRFSstatus
group <- as.factor(data2$WHcleargroup)
newdata2 <- data.frame(time,status,group)
km_fit <- survfit(Surv(time, status) ~ group, data=newdata2)
summary2 <- summary(km_fit, times = 60)


data2.1 <- data2[data2$WHcleargroup == 0 | data2$WHcleargroup == 1,]
data2.2 <- data2[data2$WHcleargroup == 0 | data2$WHcleargroup == 2,]

time <- data2.1$WHRFS
status <- data2.1$WHRFSstatus
group <- as.factor(data2.1$WHcleargroup)
f1 <- fixtdiff(time=time,status=status,group=group, testtime=60,varpooled=FALSE,trans="log")

time <- data2.2$WHRFS
status <- data2.2$WHRFSstatus
group <- as.factor(data2.2$WHcleargroup)
f2 <- fixtdiff(time=time,status=status,group=group, testtime=60,varpooled=FALSE,trans="log")

cat(5,"\n")
data5 <- read.csv("ctDNAfig5.csv")
data5 <- data5[data5$WHserial !=2,]
time <- data5$WHRFS
status <- data5$WHRFSstatus
group <- as.factor(data5$WHserial)
newdata5 <- data.frame(time,status,group)
km_fit <- survfit(Surv(time, status) ~ group, data=newdata5)
summary5 <- summary(km_fit, times = 60)

data5.1 <- data5[data5$WHserial == 0 | data5$WHserial == 1,]
data5.3 <- data5[data5$WHserial == 0 | data5$WHserial == 3,]
time <- data5.1$WHRFS
status <- data5.1$WHRFSstatus
group <- as.factor(data5.1$WHserial)
cat(5.1,"\n")
f5.1 <- fixtdiff(time=time,status=status,group=group, testtime=60,varpooled=FALSE,trans="log")
time <- data5.3$WHRFS
status <- data5.3$WHRFSstatus
group <- as.factor(data5.3$WHserial)
cat(5.3,"\n")
f5.3 <- fixtdiff(time=time,status=status,group=group, testtime=60,varpooled=FALSE,trans="log")
