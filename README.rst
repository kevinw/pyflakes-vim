WARNING: DEPRECATED! pyflakes-vim is officially deprecated!
--------------------------------------

The features of pyflakes-vim have been merged into other more widely-used and updated tools.

If you're using vim 8.0 or neovim, try ALE_ and flakes8_ instead.

.. _ALE: https://github.com/w0rp/ale
.. _flakes8: http://flake8.pycqa.org/en/latest/

On older vims you can try Syntastic_.

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

Test
----

Some tiny tests with::

    pip install -r test-requirements.txt
    py.test ftplugin/python/test_flaker.py

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

Pyflakes can use Python 2 or Python 3 compiled into Vim.  If you have both,
you can ask Pyflakes to prefer one or the other, with this in your vimrc::

    let g:pyflakes_prefer_python_version = 3

or::

    let g:pyflakes_prefer_python_version = 2

Pyflakes will chose Python 2 by default, if you have both.  If you prefer a
version that you don't have, Pyflakes will quietly fall back to the version
that you do have.

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

