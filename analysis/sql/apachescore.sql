-- query extracting apacheschore IV on admission 

SELECT 
  patientunitstayid
, apachescore 
FROM `physionet-data.eicu_crd.apachepatientresult`
where apacheversion = 'IV'