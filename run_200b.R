
outputfile="results_200b.RData"
outputfilecsv="results_200b.csv"

for(id in 1:10) {

 jobid <- pcatsAPIclientR::dynamicGP(datafile=paste0("data/200/sim",id,".csv"),
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
   method="BART",
   seed=1,
   use.cache=T,
   reuse.cached.jobid=T)

   print(jobid)

   status <- pcatsAPIclientR::wait_for_result(jobid)

   if (status$status != "Done") {
      stop(paste("Error for id", id, "status:", status$status))
   }

   result<-pcatsAPIclientR::results(jobid)

   data <- rbind(result$dynamicGP$stage2$ate, result$dynamicGP$stage1$ate)
   data <- cbind(data, var=c("Y01Y00", "Y10Y00", "Y11Y00", "Y10Y01", "Y11Y01", "Y11Y10", "Y1Y0"))
   outdata <-data.frame("Seed"=id,"Method"="GP (1.0)")
   for(i in 1:7) {
      outdata[,paste0(data[i,]$var,"")]<-data[i,]$Estimation * -1
      outdata[,paste0("SD.",data[i,]$var)]<-data[i,]$SD
      outdata[,paste0("Lb.",data[i,]$var)]<-data[i,]$UB * -1
      outdata[,paste0("Ub.",data[i,]$var)]<-data[i,]$LB * -1
   }
   outdata[,"wall_time"] <- result$timing[3]
   outdata[,"cpu_time"] <- result$timing[1]+result$timing[2]

   if (file.exists(outputfile)) load(outputfile)
   else results <- NULL

   if (sum(results$ID==id)) {
      results[which(results$ID==id),] <- outdata
   } else {
      results <- rbind(results, outdata)
   }

   save(results,file=outputfile)
   write.csv(results, file=outputfilecsv, row.names=FALSE)
}
