

for(id in 1:100) {

 jobid <- pcatsAPIclientR::dynamicGP(datafile=paste0("data/600/sim",id,".csv"),
   stg1.outcome="Y1",
   stg1.treatment="A1",
   stg1.x.explanatory="X,Z",
   stg1.x.confounding="X,Z",
   stg1.outcome.type="Continuous",
   stg1.tr.hte="Z",
   stg1.tr.type = "Discrete",
   stg2.outcome="Y2",
   stg2.treatment="A2",
   stg2.x.explanatory="X,Y1,Z",
   stg2.x.confounding="X,Y1,Z",
   stg2.outcome.type="Continuous",
   stg2.tr2.hte="Z",
   stg2.tr.type = "Discrete",
   burn.num=2000,
   mcmc.num=2000,
   x.categorical='Z',
   method="GP",
   seed=1,
   use.cache=T)

print(jobid)

status <- pcatsAPIclientR::wait_for_result(jobid)

print(status)

if (status$status == "Done") {
   result<-pcatsAPIclientR::results(jobid)
   print(result)

   data <- rbind(result$dynamicGP$stage1$ate, result$dynamicGP$stage2$ate)
   data <- cbind(data, var=c("Y1Y0", "Y01Y00", "Y10Y00", "Y11Y00", "Y10Y01", "Y11Y01", "Y11Y10"))
   outdata <-data.frame("ID"=id)
   for(i in 1:7) {
      outdata[,paste0(data[i,]$var,".Estimation")]<-data[i,]$Estimation * -1
      outdata[,paste0(data[i,]$var,".SD")]<-data[i,]$SD
      outdata[,paste0(data[i,]$var,".LB")]<-data[i,]$LB * -1
      outdata[,paste0(data[i,]$var,".UB")]<-data[i,]$UB * -1
   }
   print(outdata)
}

}
