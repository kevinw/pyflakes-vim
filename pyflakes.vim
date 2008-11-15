" pyflakes.vim - A script to highlight Python code on the fly with warnings
" from Pyflakes, a Python lint tool.
"
" Place this script and the accompanying pyflakes directory in
" .vim/after/ftplugin/python.
"
" Maintainer: Kevin Watters <kevin.watters@gmail.com>
" Version: 0.1
"
" Thanks to matlib.vim for ideas/code on interactive linting.

if exists("b:did_pyflakes_plugin")
    finish " only load once
else
    let b:did_pyflakes_plugin = 1
end

if !exists("b:did_python_init")
    python << EOF
import vim
import os.path
import sys

# get the directory this script is in: the pyflakes python module should be installed there.
scriptdir = os.path.join(os.path.dirname(vim.eval('expand("<sfile>")')), 'pyflakes')
sys.path.insert(0, scriptdir)

from pyflakes import checker, ast, messages
from operator import attrgetter

class SyntaxError(messages.Message):
    message = 'could not compile: %s'
    def __init__(self, filename, lineno, col, message):
        messages.Message.__init__(self, filename, lineno, col)
        self.message_args = (message,)

def check(buffer):
    filename = buffer.name
    contents = '\n'.join(buffer[:])

    try:
        tree = ast.parse(contents, filename)
    except:
        try:
            value = sys.exc_info()[1]
            lineno, offset, line = value[1][1:]
        except IndexError:
            lineno, offset, line = 1, 0, ''
        if line.endswith("\n"):
            line = line[:-1]

        return [SyntaxError(filename, lineno, offset, str(value))]
    else:
        w = checker.Checker(tree, filename)
        w.messages.sort(key = attrgetter('lineno'))
        return w.messages


def vim_quote(s):
    return s.replace("'", "''")
EOF
    let b:did_python_init = 1
endif

au BufWinLeave <buffer> call s:ClearPyflakes()
au BufEnter <buffer> call s:RunPyflakes()
au InsertLeave <buffer> call s:RunPyflakes()

au CursorHold <buffer> call s:RunPyflakes()
au CursorHold <buffer> call s:GetPyflakesMessage()
au CursorMoved <buffer> call s:GetPyflakesMessage()
au CursorHoldI <buffer> call s:RunPyflakes()

" WideMsg() prints [long] message up to (&columns-1) length
" guaranteed without "Press Enter" prompt.
if !exists("*s:WideMsg")
    function s:WideMsg(msg)
        let x=&ruler | let y=&showcmd
        set noruler noshowcmd
        redraw
        echo a:msg
        let &ruler=x | let &showcmd=y
    endfun
endif

if !exists("*s:RunPyflakes")
    function s:RunPyflakes()
        highlight PyFlakes term=underline gui=undercurl guisp=Orange

        if exists("b:cleared")
            if b:cleared == 0
                silent call s:ClearPyflakes()
                let b:cleared = 1
            endif
        else
            let b:cleared = 1
        endif
        
        let b:matched = []
        let b:matchedlines = {}
        python << EOF
for w in check(vim.current.buffer):
    vim.command('let s:matchDict = {}')
    vim.command("let s:matchDict['lineNum'] = " + str(w.lineno))
    vim.command("let s:matchDict['message'] = '%s'" % vim_quote(w.message % w.message_args))
    vim.command("let b:matchedlines[" + str(w.lineno) + "] = s:matchDict")

    if w.col is None:
        # without column information, just highlight the whole line
        # (minus the newline)
        vim.command(r"let s:mID = matchadd('PyFlakes', '\%" + str(w.lineno) + r"l\n\@!')")
    else:
        # with a column number, highlight the first keyword there
        vim.command(r"let s:mID = matchadd('PyFlakes', '^\%" + str(w.lineno) + r"l\_.\{-}\zs\k\+\k\@!\%>" + str(w.col) + r"c')")

    vim.command("call add(b:matched, s:matchDict)")
EOF
        let b:cleared = 0
    endfunction
end

" keep track of whether or not we are showing a message
let b:showing_message = 0

if !exists("*s:GetPyflakesMessage")
    function s:GetPyflakesMessage()
        let s:cursorPos = getpos(".")

        " if there's a message for the line the cursor is currently on, echo
        " it to the console
        if has_key(b:matchedlines, s:cursorPos[1])
            let s:pyflakesMatch = get(b:matchedlines, s:cursorPos[1])
            call s:WideMsg(s:pyflakesMatch['message'])
            let b:showing_message = 1
            return
        endif

        " otherwise, if we're showing a message, clear it
        if b:showing_message == 1
            echo
            let b:showing_message = 0
        endif
    endfunction
endif

if !exists('*s:ClearPyflakes')
    function s:ClearPyflakes()
        let s:matches = getmatches()
        for s:matchId in s:matches
            if s:matchId['group'] == 'PyFlakes'
                call matchdelete(s:matchId['id'])
            endif
        endfor
        let b:matched = []
        let b:matchedlines = {}
        let b:cleared = 1
    endfunction
endif

