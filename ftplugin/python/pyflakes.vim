" pyflakes.vim - A script to highlight Python code on the fly with warnings
" from Pyflakes, a Python lint tool.
"
" Place this script and the accompanying pyflakes directory in
" .vim/ftplugin/python.
"
" See README for additional installation and information.
"
" Thanks to matlib.vim for ideas/code on interactive linting.
"
" Maintainer: Kevin Watters <kevin.watters@gmail.com>
" Version: 0.1

if exists("b:did_pyflakes_plugin")
    finish " only load once
else
    let b:did_pyflakes_plugin = 1
endif

if !exists('g:pyflakes_builtins')
    let g:pyflakes_builtins = []
endif

if !exists("b:did_python_init")
    let b:did_python_init = 0

    if !has('python') && !has('python3')
        echoerr "Error: Requires Vim compiled with +python or +python3"
        finish
    endif
    " Default to Python 2
    if has('python')
        let py_cmd_ver = 'python'
    else
        let py_cmd_ver = 'python3'
    endif
    if exists('g:pyflakes_prefer_python_version')
        if g:pyflakes_prefer_python_version == 3 && has('python3')
            let py_cmd_ver = 'python3'
        elseif g:pyflakes_prefer_python_version == 2 && has('python')
            let py_cmd_ver = 'python'
        endif
    endif
    if py_cmd_ver == 'python'
        command! -nargs=1 Python python <args>
    else
        command! -nargs=1 Python python3 <args>
    endif

    if !exists('g:pyflakes_use_quickfix')
        let g:pyflakes_use_quickfix = 1
    endif

Python << EOF
import vim
from os.path import dirname, join as pjoin
import sys

if sys.version_info[:2] < (2, 5):
    raise AssertionError('Vim must be compiled with Python 2.5 or higher; you have ' + sys.version)

# get the directory this script is in: the pyflakes python module should be installed there.
script_dir = dirname(vim.eval('expand("<sfile>")'))
flakes_dir = pjoin(script_dir, 'pyflakes')
for path in (script_dir, flakes_dir):
    if path not in sys.path:
        sys.path.insert(0, path)

from flaker import check, vim_quote, SyntaxError
EOF
    let b:did_python_init = 1
endif

if !b:did_python_init
    finish
endif

au BufLeave <buffer> call s:ClearPyflakes()

au BufEnter <buffer> call s:RunPyflakes()
au InsertLeave <buffer> call s:RunPyflakes()
au InsertEnter <buffer> call s:RunPyflakes()
au BufWritePost <buffer> call s:RunPyflakes()

au CursorHold <buffer> call s:RunPyflakes()
au CursorHoldI <buffer> call s:RunPyflakes()

au CursorHold <buffer> call s:GetPyflakesMessage()
au CursorMoved <buffer> call s:GetPyflakesMessage()

if !exists("*s:PyflakesUpdate")
    function s:PyflakesUpdate()
        silent call s:RunPyflakes()
        call s:GetPyflakesMessage()
    endfunction
endif

" Call this function in your .vimrc to update PyFlakes
if !exists(":PyflakesUpdate")
  command PyflakesUpdate :call s:PyflakesUpdate()
endif

" Hook common text manipulation commands to update PyFlakes
"   TODO: is there a more general "text op" autocommand we could register
"   for here?
noremap <buffer><silent> dd dd:PyflakesUpdate<CR>
noremap <buffer><silent> dw dw:PyflakesUpdate<CR>
noremap <buffer><silent> u u:PyflakesUpdate<CR>
noremap <buffer><silent> <C-R> <C-R>:PyflakesUpdate<CR>

" WideMsg() prints [long] message up to (&columns-1) length
" guaranteed without "Press Enter" prompt.
if !exists("*s:WideMsg")
    function s:WideMsg(msg)
        let x=&ruler | let y=&showcmd
        set noruler noshowcmd
        redraw
        echo strpart(a:msg, 0, &columns-1)
        let &ruler=x | let &showcmd=y
    endfun
endif

if !exists("*s:GetQuickFixStackCount")
    function s:GetQuickFixStackCount()
        let l:stack_count = 0
        try
            silent colder 9
        catch /E380:/
        endtry

        try
            for i in range(9)
                silent cnewer
                let l:stack_count = l:stack_count + 1
            endfor
        catch /E381:/
            return l:stack_count
        endtry
    endfunction
endif

if !exists("*s:ActivatePyflakesQuickFixWindow")
    function s:ActivatePyflakesQuickFixWindow()
        try
            silent colder 9 " go to the bottom of quickfix stack
        catch /E380:/
        catch /E788:/
        endtry

        if s:pyflakes_qf > 0
            try
                exe "silent cnewer " . s:pyflakes_qf
            catch /E381:/
                echoerr "Could not activate Pyflakes Quickfix Window."
            endtry
        endif
    endfunction
endif

if !exists("*s:RunPyflakes")
    function s:RunPyflakes()
        highlight link PyFlakes SpellBad

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

        let b:qf_list = []
        let b:qf_window_count = -1

        Python << EOF
for w in check(vim.current.buffer):
    if not isinstance(w.lineno, int):
        lineno = str(w.lineno.lineno)
    else:
        lineno = str(w.lineno)

    vim.command('let s:matchDict = {}')
    vim.command("let s:matchDict['lineNum'] = " + lineno)
    vim.command("let s:matchDict['message'] = '%s'" % vim_quote(w.message % w.message_args))
    vim.command("let b:matchedlines[" + lineno + "] = s:matchDict")
    
    vim.command("let l:qf_item = {}")
    vim.command("let l:qf_item.bufnr = bufnr('%')")
    vim.command("let l:qf_item.filename = expand('%')")
    vim.command("let l:qf_item.lnum = %s" % lineno)
    vim.command("let l:qf_item.text = '%s'" % vim_quote(w.message % w.message_args))
    vim.command("let l:qf_item.type = 'E'")

    if getattr(w, 'col', None) is None or isinstance(w, SyntaxError):
        # without column information, just highlight the whole line
        # (minus the newline)
        vim.command(r"let s:mID = matchadd('PyFlakes', '\%" + lineno + r"l\n\@!')")
    else:
        # with a column number, highlight the first keyword there
        vim.command(r"let s:mID = matchadd('PyFlakes', '^\%" + lineno + r"l\_.\{-}\zs\k\+\k\@!\%>" + str(w.col) + r"c')")

        vim.command("let l:qf_item.vcol = 1")
        vim.command("let l:qf_item.col = %s" % str(w.col + 1))

    vim.command("call add(b:matched, s:matchDict)")
    vim.command("call add(b:qf_list, l:qf_item)")
EOF
        if g:pyflakes_use_quickfix == 1
            if exists("s:pyflakes_qf")
                " if pyflakes quickfix window is already created, reuse it
                call s:ActivatePyflakesQuickFixWindow()
                call setqflist(b:qf_list, 'r')
            else
                " one pyflakes quickfix window for all buffer
                call setqflist(b:qf_list, ' ')
                let s:pyflakes_qf = s:GetQuickFixStackCount()
            endif
        endif

        let b:cleared = 0
    endfunction
end

" keep track of whether or not we are showing a message
let b:showing_message = 0

if !exists("*s:GetPyflakesMessage")
    function s:GetPyflakesMessage()
        let s:cursorPos = getpos(".")

        " Bail if RunPyflakes hasn't been called yet.
        if !exists('b:matchedlines')
            return
        endif

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

