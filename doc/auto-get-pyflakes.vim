" This is one way to get pyflakes working easily. My Vim config uses
" vim-addon-manager and is shared between computers via VCS. Every time I put
" the config on a new computer, vam will download all plugins, but I still had
" to download the special pyflakes module for pyflakes-vim. I have figured out
" this script and now it works. Copypaste this into your vimrc, or source this
" script.

python << EOF
""" This will install pyflakes. It uses a special fork which is from the
    author of pyflakes.vim and according to him is better because it retains
    line number info.
    """
try:
  import pyflakes
except ImportError:
  import os
  # you can't use from distutils.dist import Distribution !!!!! For no
  # apparent reason!!
  from setuptools.command.easy_install import easy_install
  class easy_install_stfu(easy_install):
    """ class easy_install wouldn't shut the fuck up about the fist parameter
        not being an instance of Distribution, even though it painfully was.
        Fuck you, easy_install.
        """

    def __init__(self):
      from distutils.dist import Distribution
      dist = Distribution()
      if not isinstance(dist, Distribution):
        self.fuck() # You'd really need to want it to do it
      self.distribution = dist
      self.initialize_options()
      self._dry_run = None
      self.verbose = dist.verbose
      self.force = None
      self.help = 0
      self.finalized = 0

    def fuck(self):
      """ class easy_install goes to fuck itself.
          """
      pass

  e = easy_install_stfu()
  import distutils.errors
  try:
    e.finalize_options()
  except distutils.errors.DistutilsError:
    pass
  src_dir = os.path.realpath(os.path.join(e.install_dir, "src"))
  git_url = "git://github.com/kevinw/pyflakes.git"

  msg = "About to pip install the python pyflakes module from " + git_url
  msg += " to " + src_dir + ".\n"
  print msg

  pip = "sudo pip install "
  pip += "-e git+" + git_url + "#egg=pyflakes "
  pip += '--src="' + src_dir + '" '
  pip += '--install-option="--install-scripts=/usr/local/bin" '
  os.system(pip)

EOF

call vam#ActivateAddons(['git:git@github.com:cheater/pyflakes-vim.git'])
" automatically puts pyflakes errors in the quickfix list, and updates them as
" you edit.
