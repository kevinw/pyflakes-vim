'''
creates the pyflakes-vim.zip bundle
'''

import os.path
import zipfile

BUNDLE_FILENAME = 'pyflakes-vim.zip'

def get_directory():
    return os.path.join(
        os.path.abspath(os.path.dirname(__file__)))

def include_dir(d):
    return not any((d.startswith('.git'),
                    d.startswith('_trial_temp'),
                    d.startswith('.svn')))

def include_file(f):
    return not any((f.endswith('.pyc'),
                    f.endswith('.zip'),
                    f.startswith('.git'),
                    f == __file__,
                    f == '.DS_Store',
                    f.endswith('.diff')))

def make_dist():
    z = zipfile.ZipFile(BUNDLE_FILENAME, 'w', zipfile.ZIP_DEFLATED)
    base = get_directory()
    count = 0
    for root, dirs, files in os.walk(base):
        dirs[:] = filter(include_dir, dirs)

        for f in files:
            name = os.path.join(root, f)
            if include_file(f):
                zipname = os.path.relpath(name, base)
                print zipname
                count += 1
                z.writestr(zipname, open(name, 'rb').read())
    z.close()

    print
    print '%s is %d files, %d bytes' % (BUNDLE_FILENAME, count, os.path.getsize(BUNDLE_FILENAME))

if __name__ == '__main__':
    make_dist()
