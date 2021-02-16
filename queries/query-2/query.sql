SELECT
  HistogramBin(Jet_pt_list.element, 15, 60, 100) AS x,
  COUNT(*) AS y
FROM `{bigquery_dataset}.{input_table}`
CROSS JOIN UNNEST(Jet_pt.list) AS Jet_pt_list
GROUP BY x
ORDER BY x
