SELECT
  CAST((
    CASE
      WHEN Jet_pt_list.element < 15 THEN 15
      WHEN Jet_pt_list.element > 60 THEN 60
      ELSE Jet_pt_list.element
    END - 0.225) / 0.45 AS INT64) * 0.45 + 0.225 AS x,
  COUNT(*) AS y
FROM `{bigquery_dataset}.{input_table}`
CROSS JOIN UNNEST(Jet_pt.list) AS Jet_pt_list
GROUP BY x
ORDER BY x
