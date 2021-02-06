#!/usr/bin/env python3

import logging
from os.path import dirname, join
import sys
import time

from google.cloud import bigquery
import pandas as pd
import pytest


def test_query(query_id, pytestconfig):
    num_events = pytestconfig.getoption('num_events')
    num_events = ('-' + str(num_events)) if num_events else ''

    base_dir = dirname(__file__)
    query_dir = join(base_dir, query_id)
    query_file = join(query_dir, 'query.sql')
    ref_file = join(query_dir, 'ref{}.csv'.format(num_events))
    png_file = join(query_dir, 'plot{}.png'.format(num_events))

    bigquery_dataset = pytestconfig.getoption('bigquery_dataset')
    input_table = pytestconfig.getoption('input_table')
    input_table = input_table or \
        'Run2012B_SingleMu{}'.format(num_events.replace('-','_'))

    # Read query
    with open(query_file, 'r') as f:
        query = f.read()
    query = query.format(
        bigquery_dataset=bigquery_dataset,
        input_table=input_table,
    )

    # Run query
    client = bigquery.Client()
    start_timestamp = time.time()
    query_job = client.query(query)
    end_timestamp = time.time()
    df = query_job.to_dataframe()

    running_time = end_timestamp - start_timestamp
    logging.info('Running time: {:.2f}s'.format(running_time))

    # Freeze reference result
    if pytestconfig.getoption('freeze_result'):
        df.to_csv(ref_file, sep=',', index=False)

    # Read reference result
    df_ref = pd.read_csv(ref_file, sep=',')

    # Plot histogram
    if pytestconfig.getoption('plot_histogram'):
        from matplotlib import pyplot as plt
        plt.hist(df.x, bins=len(df.index), weights=df.y)
        plt.savefig(png_file)
        plt.close()

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
    pytest.main(sys.argv)
