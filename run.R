
for(id in 1:100) {

 jobid <- pcatsAPIclientR::dynamicGP(datafile=paste0("data/400/sim",id,".csv"),
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
   use.cache=T,
   reuse.cached.jobid=T)

   print(jobid)

   status <- pcatsAPIclientR::wait_for_result(jobid)

   if (status$status != "Done") {
      stop(paste("Error for id", id, "status:", status$status))
   }

   result<-pcatsAPIclientR::results(jobid)

   data <- rbind(result$dynamicGP$stage1$ate, result$dynamicGP$stage2$ate)
   data <- cbind(data, var=c("Y1Y0", "Y01Y00", "Y10Y00", "Y11Y00", "Y10Y01", "Y11Y01", "Y11Y10"))
   outdata <-data.frame("ID"=id)
   for(i in 1:7) {
      outdata[,paste0(data[i,]$var,".Estimation")]<-data[i,]$Estimation * -1
      outdata[,paste0(data[i,]$var,".SD")]<-data[i,]$SD
      outdata[,paste0(data[i,]$var,".LB")]<-data[i,]$LB * -1
      outdata[,paste0(data[i,]$var,".UB")]<-data[i,]$UB * -1
   }
   if (file.exists("results.RData")) load("results.RData")
   else results <- NULL

   if (sum(results$ID==id)) {
      results[which(results$ID==id),] <- outdata
   } else {
      results <- rbind(results, outdata)
   }

   save(results,file="results.RData")
   write.csv(results, file="results.csv", row.names=FALSE)
}
