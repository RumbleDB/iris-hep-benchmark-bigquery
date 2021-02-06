SELECT
  CAST((
    CASE
      WHEN MET_sumet < 0 THEN 0
      WHEN MET_sumet > 2000 THEN 2000
      ELSE MET_sumet
    END - 10) / 20 AS INT64) * 20 + 10 AS x,
  COUNT(*) AS y
FROM `{bigquery_dataset}.{input_table}`
WHERE nMuon >= 2 AND
  (SELECT COUNT(*) AS mass
   FROM UNNEST(Muon) m1 WITH OFFSET i
   CROSS JOIN UNNEST(Muon) m2 WITH OFFSET j
   WHERE
     m1.charge <> m2.charge AND i < j AND
     SQRT(2*m1.pt*m2.pt*(COSH(m1.eta-m2.eta)-COS(m1.phi-m2.phi))) BETWEEN 60 AND 100) > 0
GROUP BY x
ORDER BY x
