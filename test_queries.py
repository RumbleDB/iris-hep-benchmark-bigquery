#!/usr/bin/env python3

from os.path import dirname, join

from google.cloud import bigquery
from matplotlib import pyplot as plt
import pandas as pd


def test_query(query_id):
    basedir = dirname(__file__)
    queryfile = join(basedir, query_id, 'query.sql')
    reffile = join(basedir, query_id, 'ref.csv')
    pngfile = join(basedir, query_id, 'plot.png')

    # Read reference result
    df_ref = pd.read_csv(reffile, sep=',', names=['y', 'x'])

    # Run query
    with open(queryfile, 'r') as f:
        query = f.read()
    client = bigquery.Client()
    query_job = client.query(query)
    df = query_job.to_dataframe()

    plt.hist(df.x, bins=len(df.index), weights=df.y)
    plt.savefig(pngfile)

    # Normalize reference and query result
    df = df[df.y > 0]
    df = df[['x', 'y']]
    df.reset_index(drop=True, inplace=True)
    df_ref = df_ref[df_ref.y > 0]
    df_ref = df_ref[['x', 'y']]
    df_ref.reset_index(drop=True, inplace=True)

    # Assert correct result
    pd.testing.assert_frame_equal(df_ref, df)


if __name__ == '__main__':
    import sys
    import pytest
    pytest.main(sys.argv)
