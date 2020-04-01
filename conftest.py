import glob
from os.path import dirname, join

def pytest_addoption(parser):
    parser.addoption("--query_id", action="append", default=[],
                     help="run all combinations")


def find_queries():
    basedir = dirname(__file__)
    queryfiles = glob.glob(join(basedir, '**/query.sql'), recursive=True)
    return sorted([s[len(basedir)+1:-len('/query.sql')] for s in queryfiles])


def pytest_generate_tests(metafunc):
    if "query_id" in metafunc.fixturenames:
        queries = metafunc.config.getoption("query_id")
        queries = queries or find_queries()
        metafunc.parametrize("query_id", queries)
