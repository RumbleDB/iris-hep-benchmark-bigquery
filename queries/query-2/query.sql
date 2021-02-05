SELECT
  CAST((
    CASE
      WHEN Jet_pt_list.element < 15 THEN 15
      WHEN Jet_pt_list.element > 60 THEN 60
      ELSE Jet_pt_list.element
    END - 0.375) / 0.45 AS INT64) * 0.45 + 0.375 AS x,
  COUNT(*) AS y
FROM root_playground.Run2012B_SingleMu_small
CROSS JOIN UNNEST(Jet_pt.list) AS Jet_pt_list
GROUP BY x
ORDER BY x
