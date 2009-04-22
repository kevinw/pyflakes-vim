pyflakes-vim
============

A Vim plugin for checking Python code on the fly.

PyFlakes catches common Python errors like mistyping a variable name or
accessing a local before it is bound, and also gives warnings for things like
unused imports.

pyflakes-vim uses the output from PyFlakes to highlight the spots in your code
where 

.. _pyflakes.vim: http://www.vim.org/scripts/script.php?script_id=2441

Quick Installation
------------------

1. Make sure your ``.vimrc`` has::
 
    filetype on            " enables filetype detection
    filetype plugin on     " enables filetype specific plugins

2. Download the latest release_.

3. Unzip ``pyflakes.vim`` and the ``pyflakes`` directory into
   ``~/.vim/after/ftplugin/python`` (or somewhere similar on your
   `runtime path`_ that will be sourced for Python files).

.. _release: pyflakes-vim.zip
.. _runtime path: http://vimdoc.sourceforge.net/htmldoc/options.html#'runtimepath' 

Installation
------------

1. I recommend getting my PyFlakes_ fork, which uses the ``_ast`` module new to
   Python 2.5, and is faster and more current than PyFlakes' old usage of
   the deprecated ``compiler`` module.

.. _PyFlakes: http://github.com/kevinw/pyflakes

Hacking
-------

::

  git clone git://github.com/kevinw/pyflakes-vim.git
  cd pyflakes-vim
  git clone git://github.com/kevinw/pyflakes.git

TODO
----
 * signs_ support (show warning and error icons to left of the buffer area)
 * configuration variables

.. _signs: http://www.vim.org/htmldoc/sign.html

Changelog
---------

 - 0.1 - First release
