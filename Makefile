# Makefile targets for local build steps on Mac.
SHELL := bash
MENU_PKG_NAME=sp-installer-menu
ROOT_PREFIX=$(shell conda config --show root_prefix | cut -d ' ' -f 2)
ENV_PKGS=$(ROOT_PREFIX)/pkgs

UNAME := "$(shell uname -s)"
ifeq ($(findstring Linux,$(UNAME)),Linux)
    MACHINE=Linux
else ifeq ($(findstring Darwin,$(UNAME)),Darwin)
    MACHINE=macOS
else ifeq ($(findstring MINGW64_NT,$(UNAME)),MINGW64_NT)
    MACHINE=Windows
else ifeq ($(FINDSTRING MSYS_NT,$(UNAME)),MSYS_NT)
    MACHINE=Windows
else
    MACHINE="UNKNOWN:$(UNAME)"
endif

all: menu-pkg installer

menu-pkg:
	conda-build $(MENU_PKG_NAME) --no-anaconda-upload --croot conda-bld

installer:
	constructor recipes/scientific-python

install:
	installer -pkg Scientific-Python-*.pkg -target CurrentUserHomeDirectory

clean:
	@rm -rf conda-bld
	@rm -rf ~/.conda/constructor/*/$(MENU_PKG_NAME)*
	@if [[ $(MACHINE) == "macOS" ]]; then \
		rm -rf ~/Applications/*Scientific*; \
		rm -f Scientific-Python-*.pkg; \
	elif [[ $(MACHINE) == "Linux" ]]; then \
		rm -rf $(HOME)/Scientific-Python; \
		rm -f ./Scientific-Python-*.sh; \
		rm -f $(HOME)/.local/share/applications/scientific-python-*.desktop; \
	elif [[ $(MACHINE) == "Windows" ]]; then \
		echo "TODO cleanup Windows icons"; \
	fi
