pyflakes-vim
============

Using my pyflakes_ fork, checks your Python code on the fly.

.. _pyflakes: http://github.com/kevinw/pyflakes

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

Hacking
-------

::

  git clone git://github.com/kevinw/pyflakes-vim.git
  cd pyflakes-vim
  git clone git://github.com/kevinw/pyflakes.git

Changelog
---------

 - 0.1 - First release
