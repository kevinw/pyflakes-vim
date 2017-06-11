# coding=utf-8
import vim
import os.path
import sys

if sys.version_info[:2] < (2, 5):
    raise AssertionError('Vim must be compiled with Python 2.5 or higher; you have ' + sys.version)

# get the directory this script is in: the pyflakes python module should be installed there.
scriptdir = os.path.join(os.path.dirname(vim.eval('expand("<sfile>")')), 'pyflakes')
if scriptdir not in sys.path:
    sys.path.insert(0, scriptdir)

import ast
from pyflakes import checker, messages
from operator import attrgetter
import re

class loc(object):
    def __init__(self, lineno, col=None):
        self.lineno = lineno
        self.col_offset = col

class SyntaxError(messages.Message):
    message = 'could not compile: %s'
    def __init__(self, filename, lineno, col, message):
        messages.Message.__init__(self, filename, loc(lineno, col))
        self.message_args = (message,)
        # fix 某些情况缺少lineno导致异常
        self.lineno = lineno

class blackhole(object):
    write = flush = lambda *a, **k: None

def check(buffer):
    filename = buffer.name
    contents = buffer[:]

    # shebang usually found at the top of the file, followed by source code encoding marker.
    # assume everything else that follows is encoded in the encoding.
    for n, line in enumerate(contents):
        if n >= 2:
            break
        elif re.match(r'#.*coding[:=]\s*([-\w.]+)', line):
            contents = ['']*(n+1) + contents[n+1:]
            break

    contents = '\n'.join(contents) + '\n'

    if sys.version_info[0] < 3:
        vimenc = vim.eval('&encoding')
        if vimenc:
            contents = contents.decode(vimenc)

    builtins = set(['__file__'])
    try:
        builtins.update(set(eval(vim.eval('string(g:pyflakes_builtins)'))))
    except Exception:
        pass

    try:
        # TODO: use warnings filters instead of ignoring stderr
        old_stderr, sys.stderr = sys.stderr, blackhole()
        try:
            tree = ast.parse(contents, filename or '<unknown>')
        finally:
            sys.stderr = old_stderr
    except:
        try:
            value = sys.exc_info()[1]
            if sys.version_info[0] < 3:
                lineno, offset, line = value[1][1:]
            else:
                lineno, offset, line = value.lineno, value.offset, ''
        except IndexError:
            lineno, offset, line = 1, 0, ''
        if line and line.endswith("\n"):
            line = line[:-1]

        return [SyntaxError(filename, lineno, offset, str(value))]
    else:
        # pyflakes looks to _MAGIC_GLOBALS in checker.py to see which
        # UndefinedNames to ignore
        old_globals = getattr(checker,' _MAGIC_GLOBALS', [])
        checker._MAGIC_GLOBALS = set(old_globals) | builtins

        filename = '(none)' if filename is None else filename
        w = checker.Checker(tree, filename)

        checker._MAGIC_GLOBALS = old_globals

        w.messages.sort(key = attrgetter('lineno'))
        return w.messages


def vim_quote(s):
    return s.replace("'", "''")
