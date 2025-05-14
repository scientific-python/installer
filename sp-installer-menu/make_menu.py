#!/usr/bin/env python3
""" Replace some markers in the JSON and other files; copy and rename others

Note that there are various {{ VAR }} Jinja template markers left in the JSON
file, but these are for processing by ``menuinst`` - see:$
`https://github.com/conda/menuinst/blob/1866363f197e0633fae0db8569119d102ca8d9cc/menuinst/platforms/base.py#L80`_
"""

from os import environ
from pathlib import Path
from shutil import copyfile

# https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html
in_path = Path(environ['RECIPE_DIR']) / 'menu'
prefix = environ['PREFIX']
out_path = Path(prefix) / 'Menu'
pkg_name = environ['PKG_NAME']
pkg_version = environ['PKG_VERSION']

if not out_path.is_dir():
    out_path.mkdir(parents=True)


def txt_replace(txt):
    for start, end in (('#PREFIX#', prefix),
                       ('#PKG_NAME#', pkg_name),
                       ('#PKG_VERSION#', pkg_version)):
        txt = txt.replace(start, end)
    return txt


menu_txt = (in_path / 'menu.json').read_text()
(out_path / f'{pkg_name}.json').write_text(txt_replace(menu_txt))


for fstem in ('console', 'info', 'web', 'forum'):
    for ext in ('icns', 'ico', 'png'):
        copyfile(in_path / f'{fstem}.{ext}',
                 out_path / f'{pkg_name}_{fstem}.{ext}')

# use hash as separator, as prefix contains forward slashes!
for fname in ('open_prompt.applescript', 'open_prompt.sh', 'open_prompt.bat'):
    in_txt = (in_path / fname).read_text()
    (out_path / f'{pkg_name}_{fname}').write_text(txt_replace(in_txt))

for fname in ('spi_sys_info.py', 'spi_mac_folder_icon.png'):
    copyfile(in_path / fname, out_path / fname)
