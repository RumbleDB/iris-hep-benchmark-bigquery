With GoodJetSumPt AS (
  SELECT
    (
      SELECT SUM(j.pt)
      FROM UNNEST(Jet) AS j
      WHERE
        j.pt > 30 AND
        NOT EXISTS
          (SELECT * FROM UNNEST(Muon) m
           WHERE m.pt > 10 AND DeltaR(j, m) < 0.4) AND
        NOT EXISTS
          (SELECT * FROM UNNEST(Electron) e
           WHERE e.pt > 10 AND DeltaR(j, e) < 0.4)
     ) AS sumPt
  FROM `{bigquery_dataset}.{input_table}`
  WHERE nJet > 0
)
SELECT
  CAST((
    CASE
      WHEN sumPt < 15 THEN 15
      WHEN sumPt > 200 THEN 200
      ELSE sumPt
    END - 0.925) / 1.85 AS INT64) * 1.85 + 0.925 AS x,
  COUNT(*) AS y
FROM GoodJetSumPt
WHERE sumPt IS NOT NULL
GROUP BY x
ORDER BY x
