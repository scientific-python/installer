# Makefile targets for local build steps on Mac.
all: menu-pkg installer

menu-pkg:
	conda-build sp-installer-menu

installer:
	constructor recipes/scientific-python

install:
	installer -pkg Scientific-Python-*.pkg -target CurrentUserHomeDirectory

clean:
	rm -rf ~/Applications/*Scientific*
	rm Scientific-Python-*.pkg
	mamba clean --all -y
	conda build purge
