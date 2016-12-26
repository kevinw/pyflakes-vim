This is a pyflakes-vim fork aiming at python3 compatibility, it does not mean
I aim to support it seriously, as I really don’t know anything about VimL, but
I want to make it at least usable for me.

Syntastic is way too heavy for me, and the original pyflakes-vim has no python 3
support (and when you use some non-python2 syntax it is basically useless).
vim-flake8 is good but has no on-the-fly checking and error highlight, so I find
it less useful.

Anyway, here are my changes, they require a python3-capable vim, and you cannot
use the plugin with most python2 code as the syntax is somewhat different and vim
doesn’t make a difference between python 2 and python 3 when activating plugins.

And for some reason, the pyflakes master branch doesn’t work, so I removed the
submodule; pyflakes needs to be installed separately.

Original README below.

pyflakes-vim is officially deprecated!
--------------------------------------

The must-have features of pyflakes-vim have been merged into Syntastic_, which
has a plugin-based syntax checking backend. This means you can check many
different languages on the fly. I recommend using Syntastic_ unless you're
mostly just editing Python.

.. _Syntastic: https://github.com/scrooloose/syntastic

pyflakes-vim
============

A Vim plugin for checking Python code on the fly.

PyFlakes catches common Python errors like mistyping a variable name or
accessing a local before it is bound, and also gives warnings for things like
unused imports.

pyflakes-vim uses the output from PyFlakes to highlight errors in your code.
To locate errors quickly, use quickfix_ commands like :cc.

Make sure to check vim.org_ for the latest updates.

.. _pyflakes.vim: http://www.vim.org/scripts/script.php?script_id=2441
.. _vim.org: http://www.vim.org/scripts/script.php?script_id=2441
.. _quickfix: http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix

Quick Installation
------------------

1. Make sure your ``.vimrc`` has::
 
    filetype on            " enables filetype detection
    filetype plugin on     " enables filetype specific plugins

2. Download the latest release_.

3. If you're using pathogen_, unzip the contents of ``pyflakes-vim.zip`` into
   its own bundle directory, i.e. into ``~/.vim/bundle/pyflakes-vim/``.

   Otherwise unzip ``pyflakes.vim`` and the ``pyflakes`` directory into
   ``~/.vim/ftplugin/python`` (or somewhere similar on your
   `runtime path`_ that will be sourced for Python files).

.. _release: http://www.vim.org/scripts/script.php?script_id=2441
.. _pathogen: http://www.vim.org/scripts/script.php?script_id=2332
.. _runtime path: http://vimdoc.sourceforge.net/htmldoc/options.html#'runtimepath' 

Running from source
-------------------

If you're running pyflakes-vim "from source," you'll need the PyFlakes library
on your PYTHONPATH somewhere.  (It is included in the vim.org zipfile.) I recommend
getting the github.com/pyflakes PyFlakes_ fork, which retains column number
information, giving more specific error locations.

.. _vim.org: http://www.vim.org/scripts/script.php?script_id=2441
.. _PyFlakes: http://github.com/pyflakes/pyflakes

Hacking
-------

::

  git clone --recursive git://github.com/kevinw/pyflakes-vim.git

or use the PyFlakes_ submodule::

  git clone git://github.com/kevinw/pyflakes-vim.git
  cd pyflakes-vim
  git submodule init
  git submodule update
 

Options
-------

Set this option in your vimrc file to disable quickfix support::
    
    let g:pyflakes_use_quickfix = 0

The value is set to 1 by default.

TODO
----
 * signs_ support (show warning and error icons to left of the buffer area)
 * configuration variables
 * parse or intercept useful output from the warnings module

.. _signs: http://vimdoc.sourceforge.net/htmldoc/sign.html

Changelog
---------

Please see http://www.vim.org/scripts/script.php?script_id=2441 for a history of
all changes.

