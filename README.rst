pyflakes-vim
============

Using my pyflakes_ fork, checks your Python code on the fly.

.. _pyflakes: http://github.com/kevinw/pyflakes

Quick Installation
------------------

::

  mkdir -p ~/.vim/after/ftplugin/python && cd !$
  git clone git://github.com/kevinw/pyflakes-vim.git
  git clone git://github.com/kevinw/pyflakes

Installation
------------

Make sure your .vimrc has

::

    filetype on
    filetype plugin on

Place pyflakes.vim and the pyflakes directory in ~/.vim/after/ftplugin/python
(or somewhere similar on your runtime path).
