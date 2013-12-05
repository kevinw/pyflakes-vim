# coding=utf-8
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

