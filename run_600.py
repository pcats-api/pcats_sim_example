import csv
import json
import os.path
from os import path
import pcats_api_client as pcats_api

outputfilecsv="pyresults_600.csv"

for id in range(1,10):
   jobid=pcats_api.dynamicgp(datafile="data/600/sim{}.csv".format(id),
      stg1_outcome="Y1",
      stg1_treatment="A1",
      stg1_x_explanatory="X,Z",
      stg1_x_confounding="X,Z",
      stg1_outcome_type="Continuous",
      stg1_tr_hte="Z",
      stg1_tr_type = "Discrete",
      stg2_outcome="Y2",
      stg2_treatment="A2",
      stg2_x_explanatory="X,Y1,Z",
      stg2_x_confounding="X,Y1,Z",
      stg2_outcome_type="Continuous",
      stg2_tr2_hte="Z",
      stg2_tr_type="Discrete",
      burn_num=2000,
      mcmc_num=2000,
      x_categorical='Z',
      method="GP",
      seed=1,
      use_cache=1,
      reuse_cached_jobid=1)

   print("JobID: {}".format(jobid))

   status = pcats_api.wait_for_result(jobid)

   if status!="Done":
       print("Error")
       continue

   result_raw = pcats_api.results(jobid)

   result = json.loads(result_raw)

   data = result['dynamicGP']['stage2']['ate']+result['dynamicGP']['stage1']['ate']

   outdata = dict()
   outdata['Seed'] = id
   outdata['Method'] = "GP (1.0)"
   var=["Y01Y00", "Y10Y00", "Y11Y00", "Y10Y01", "Y11Y01", "Y11Y10", "Y1Y0"]
   for i in range(0,7):
      outdata[var[i]]=data[i]['Estimation'] * -1
      outdata["SD."+var[i]]=data[i]['SD']
      outdata["Lb."+var[i]]=data[i]['UB'] * -1
      outdata["Ub."+var[i]]=data[i]['LB'] * -1

   outdata['wall_time'] = result['timing'][2]
   outdata['cpu_time'] = result['timing'][0]+result['timing'][1]

   infile = list()

   if path.exists(outputfilecsv):
     with open(outputfilecsv, 'r') as csvfile:
       reader = csv.DictReader(csvfile, list(outdata.keys()))
       next(reader, None)  # skip the headers
       for row in reader:
          infile.append(row)

   if len(infile)>=id: 
      infile[id-1] = outdata
   else:
      infile.append(outdata)

   with open(outputfilecsv, 'w') as csvfile:
     writer = csv.DictWriter(csvfile, fieldnames=list(outdata.keys()))
     writer.writeheader()
     for row in infile:
        writer.writerow(row)
