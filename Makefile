# Makefile targets for local build steps on Mac.

MENU_PKG_NAME=sp-installer-menu

all: menu-pkg installer

menu-pkg:
	conda-build $(MENU_PKG_NAME)

installer:
	constructor recipes/scientific-python

install:
	installer -pkg Scientific-Python-*.pkg -target CurrentUserHomeDirectory

foo:
	BAR=baz
	echo $(BAR)

clean: ROOT_PREFIX=$(shell conda config --show root_prefix | cut -d ' ' -f 2)
clean:
	rm -rf $(ROOT_PREFIX)/pkgs/$(MENU_PKG_NAME)*
	rm -rf $(ROOT_PREFIX)/conda-bld
	rm -rf ~/Applications/*Scientific*
	rm -f Scientific-Python-*.pkg
	# These may not add useful cleanliness.
	mamba clean --all -y
	conda build purge
