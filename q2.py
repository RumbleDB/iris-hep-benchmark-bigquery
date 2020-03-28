#!/usr/bin/env python3

from google.cloud import bigquery
from matplotlib import pyplot as plt

client = bigquery.Client()
query = """
    SELECT
      CASE
      WHEN Jet_pt_list.element < 15 THEN 15
      WHEN Jet_pt_list.element > 60 THEN 60
      ELSE CAST(Jet_pt_list.element / 0.45 AS INT64) END * 0.45 AS Jet_pt_rounded,
      COUNT(*) AS count
    FROM root_playground.Run2012B_SingleMu_small
    CROSS JOIN UNNEST(Jet_pt.list) AS Jet_pt_list
    GROUP BY Jet_pt_rounded
    ORDER BY Jet_pt_rounded;
    """
query_job = client.query(query)
df = query_job.to_dataframe()

plt.hist(df['Jet_pt_rounded'], bins=len(df.index), weights=df['count'])
plt.show()
