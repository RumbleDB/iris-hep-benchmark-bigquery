#!/usr/bin/env python3

from google.cloud import bigquery
from matplotlib import pyplot as plt

client = bigquery.Client()
query = """
    SELECT
      CASE WHEN MET_sumet < 0 THEN 0
           WHEN MET_sumet > 2000 THEN 100
           ELSE CAST(MET_sumet / 20 AS INT64) END * 20 AS MET_sumet_rounded,
      COUNT(*) AS count
    FROM root_playground.Run2012B_SingleMu_small
    GROUP BY MET_sumet_rounded
    ORDER BY MET_sumet_rounded
    """
query_job = client.query(query)
df = query_job.to_dataframe()

plt.hist(df['MET_sumet_rounded'], bins=len(df.index), weights=df['count'])
plt.show()
