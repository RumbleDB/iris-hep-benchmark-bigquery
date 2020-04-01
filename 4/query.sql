SELECT
  CASE WHEN MET_sumet < 0 THEN 0
       WHEN MET_sumet > 2000 THEN 100
       ELSE CAST(MET_sumet / 20 AS INT64) END * 20 AS x,
  COUNT(*) AS y
FROM root_playground.Run2012B_SingleMu_small_Jets
WHERE (SELECT COUNT(*) FROM UNNEST(JET) WHERE pt > 40 AND ABS(eta) < 1.0) > 1
GROUP BY x
ORDER BY x
