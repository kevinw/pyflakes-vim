""" Code for running pyflakes checks in Vim buffer

The main function is ``check``, which runs the pyflakes check on a buffer.
"""

import sys
import ast
from operator import attrgetter
import re

from pyflakes import checker, messages

try:
    # Vim module available within vim
    import vim
except ImportError:
    # Otherwise, mock it up for tests
    from mock import Mock
    vim = Mock()


class loc(object):

    def __init__(self, lineno, col=None):
        self.lineno = lineno
        self.col_offset = col


class SyntaxError(messages.Message):

    message = 'could not compile: %s'

    def __init__(self, filename, lineno, col, message):
        messages.Message.__init__(self, filename, loc(lineno, col))
        self.message_args = (message,)
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

    vimenc = vim.eval('&encoding')
    if vimenc and hasattr(contents, 'decode'):
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
        exc_value = sys.exc_info()[1]
        try:
            lineno, offset, line = exc_value.args[1][1:]
        except IndexError:
            lineno, offset, line = 1, 0, ''
        if line and line.endswith("\n"):
            line = line[:-1]

        return [SyntaxError(filename, lineno, offset, str(exc_value))]
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
