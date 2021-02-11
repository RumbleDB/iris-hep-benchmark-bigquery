SELECT
  CAST((
    CASE
      WHEN MET_sumet < 0 THEN 0
      WHEN MET_sumet > 2000 THEN 2000
      ELSE MET_sumet
    END - 10) / 20 AS INT64) * 20 + 10 AS x,
  COUNT(*) AS y
FROM `{bigquery_dataset}.{input_table}`
WHERE (SELECT COUNT(*) FROM UNNEST(JET) WHERE pt > 40) > 1
GROUP BY x
ORDER BY x
