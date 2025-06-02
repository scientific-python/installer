# Makefile targets for local build steps on Mac.
SHELL := bash
ENV_EXE ?= conda
PROJECT_NAME=Scientific-Python
PROJECT_NAME_LOWER=$(shell echo $(PROJECT_NAME) | tr A-Z a-z)

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
	constructor recipes/$(PROJECT_NAME_LOWER)

install:
	@if [[ $(MACHINE) == "macOS" ]]; then \
		installer -pkg $(PROJECT_NAME)-*.pkg -target CurrentUserHomeDirectory; \
	elif [[ $(MACHINE) == "Linux" ]]; then \
		sh ./$(PROJECT_NAME)-*-Linux.sh; \
	elif [[ $(MACHINE) == "Windows" ]]; then \
		echo "TODO add install command for Windows"; \
	fi

env:
	$(ENV_EXE) env create -y -f environment.yml

clean:
	@rm -rf conda-bld
	@rm -rf ~/.conda/constructor/*/$(MENU_PKG_NAME)*
	@if [[ $(MACHINE) == "macOS" ]]; then \
		rm -rf ~/Applications/$(PROJECT_NAME)*; \
		rm -f Scientific-Python-*.pkg; \
	elif [[ $(MACHINE) == "Linux" ]]; then \
		rm -rf $(HOME)/Scientific-Python; \
		rm -f ./Scientific-Python-*.sh; \
		rm -f $(HOME)/.local/share/applications/$(PROJECT_NAME_LOWER)-*.desktop; \
	elif [[ $(MACHINE) == "Windows" ]]; then \
		echo "TODO add command to cleanup icons on Windows"; \
	fi
