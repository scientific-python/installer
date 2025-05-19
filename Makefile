# Makefile targets for local build steps on Mac.

MENU_PKG_NAME=sp-installer-menu
ROOT_PREFIX=$(shell conda config --show root_prefix | cut -d ' ' -f 2)
ENV_PKGS=$(ROOT_PREFIX)/pkgs

all: menu-pkg installer

menu-pkg:
	conda-build $(MENU_PKG_NAME) --no-test --no-anaconda-upload --croot conda-bld

installer:
	constructor recipes/scientific-python

install:
	installer -pkg Scientific-Python-*.pkg -target CurrentUserHomeDirectory

clean:
	rm -rf conda-bld
	rm -rf ~/.conda/constructor/*/$(MENU_PKG_NAME)*
	rm -rf ~/Applications/*Scientific*
	rm -f Scientific-Python-*.pkg
