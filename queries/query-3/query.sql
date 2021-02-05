SELECT
  CAST((
    CASE
      WHEN pt < 15 THEN 15
      WHEN pt > 60 THEN 60
      ELSE pt
    END - 0.375) / 0.45 AS INT64) * 0.45 + 0.375 AS x,
  COUNT(*) AS y
FROM root_playground.Run2012B_SingleMu_small_Jets
CROSS JOIN UNNEST(Jet)
WHERE eta > 1
GROUP BY x
ORDER BY x
