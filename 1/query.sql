SELECT
  CAST((
    CASE
      WHEN MET_sumet < 0 THEN 0
      WHEN MET_sumet > 2000 THEN 2000
      ELSE MET_sumet
    END - 10) / 20 AS INT64) * 20 + 10 AS x,
  COUNT(*) AS y
FROM root_playground.Run2012B_SingleMu_small
GROUP BY x
ORDER BY x
