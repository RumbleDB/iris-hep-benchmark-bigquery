SELECT
  CAST((
    CASE
      WHEN pt < 15 THEN 15
      WHEN pt > 60 THEN 60
      ELSE pt
    END - 0.225) / 0.45 AS INT64) * 0.45 + 0.225 AS x,
  COUNT(*) AS y
FROM `{bigquery_dataset}.{input_table}`
CROSS JOIN UNNEST(Jet)
WHERE ABS(eta) < 1
GROUP BY x
ORDER BY x
