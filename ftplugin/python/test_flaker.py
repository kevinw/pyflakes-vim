""" Test flaker module

The flaker module contains Python functions used by the Vim code.

Run with::

    pip install nose pytest
    py.test test_flaker.py
"""

from os.path import dirname, join as pjoin
import sys

# Put our copy of pyflakes on the PATH
sys.path.insert(0, pjoin(dirname(__file__), 'pyflakes'))

import flaker


class Buffer(object):

    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)

    def __getitem__(self, slicer):
        return self.contents[slicer]


def test_check():
    # Try a syntax error
    buffer = Buffer(name='foo', contents = ["First line\n"])
    ret = flaker.check(buffer)
    assert len(ret) == 1
    assert isinstance(ret[0], flaker.SyntaxError)
    # Code OK, empty list returned
    buffer = Buffer(name='foo', contents = ["a = 1\n"])
    assert flaker.check(buffer) == []
