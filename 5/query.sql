SELECT
  CASE WHEN MET_sumet < 0 THEN 0
       WHEN MET_sumet > 2000 THEN 100
       ELSE CAST(MET_sumet / 20 AS INT64) END * 20 AS x,
  COUNT(*) AS y
FROM root_playground.Run2012B_SingleMu_small_JetsMuons
WHERE nMuon >= 2 AND
  (SELECT COUNT(*) AS mass
   FROM UNNEST(Muon) m1 WITH OFFSET i
   CROSS JOIN UNNEST(Muon) m2 WITH OFFSET j
   WHERE
     m1.charge <> m2.charge AND i < j AND
     SQRT(2*m1.pt*m2.pt*(COSH(m1.eta-m2.eta)-COS(m1.phi-m2.phi))) BETWEEN 60 AND 100) > 0
GROUP BY x
ORDER BY x
