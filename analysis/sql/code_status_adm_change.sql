-- Cplit item on admission
-- when there is a change and what was it.
--
-- the First sq gets the code status at admission
-- 22669 icu stays
-- we also get Care Limitation initial code status when there is no change afterwards


WITH
  sq1 AS(
  SELECT
    patientunitstayid,
    cplitemvalue AS adm_code_status,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY cplitemoffset ASC) AS position
  FROM
    `physionet-data.eicu_crd.careplangeneral`
  WHERE
    cplgroup = 'Care Limitation'
    AND cplitemoffset BETWEEN -6*60
    AND 24*60 ),
  sq1_final AS(
  SELECT
    patientunitstayid,
    adm_code_status
  FROM
    sq1
  WHERE
    position =1 ),
  sq2 AS(
  SELECT
    patientunitstayid,
    cplitemvalue AS adm_code_status_change,
    ROUND( cplitemoffset /60,2) adm_code_status_change_hrs -- hours from icu admission when code status changed
    ,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY cplitemoffset ASC) AS position_changed
  FROM
    `physionet-data.eicu_crd.careplangeneral`
  WHERE
    cplgroup = 'Care Limitation'
    AND cplitemoffset BETWEEN -6*60
    AND 24*60*10),
  sq2_final AS (
  SELECT
    patientunitstayid,
    adm_code_status_change,
    adm_code_status_change_hrs
  FROM
    sq2
  WHERE
    position_changed = 2 )
SELECT
  sq1_final.patientunitstayid,
  adm_code_status,
  adm_code_status_change,
  adm_code_status_change_hrs
FROM
  sq1_final
LEFT JOIN
  sq2_final
ON
  sq1_final.patientunitstayid = sq2_final.patientunitstayid
ORDER BY
  patientunitstayid
