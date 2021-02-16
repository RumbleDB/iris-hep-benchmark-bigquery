WITH RunWithTriJets AS (
  SELECT *,
    (SELECT [j1, j2, j3]
     FROM UNNEST(Jet) j1 WITH OFFSET i,
          UNNEST(Jet) j2 WITH OFFSET j,
          UNNEST(Jet) j3 WITH OFFSET k
     WHERE i < j AND j < k
     ORDER BY abs(TriJetMass(STRUCT(j1.Pt, j1.Eta, j1.Phi, j1.Mass),
                             STRUCT(j2.Pt, j2.Eta, j2.Phi, j2.Mass),
                             STRUCT(j3.Pt, j3.Eta, j3.Phi, j3.Mass)) - 172.5) ASC
     LIMIT 1) AS TriJet
  FROM `{bigquery_dataset}.{input_table}`
  WHERE nJet >= 3
),
MaxBTags AS (
  SELECT (SELECT MAX(tj.btag) FROM UNNEST(TriJet) AS tj) AS maxBtag
  FROM RunWithTriJets
)
SELECT
  HistogramBin(maxBtag, 0, 1, 100) AS x,
  COUNT(*) AS y
FROM MaxBTags
GROUP BY x
ORDER BY x
