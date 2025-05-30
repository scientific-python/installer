#!/bin/bash

# This is used to initialize the bash prompt on macOS and Linux.

if [[ -f ~/.bashrc ]] && [[ ${OSTYPE} != 'darwin'* ]]; then
    source ~/.bashrc
fi
source "#PREFIX#/bin/activate" base
export JUPYTER_CONFIG_DIR="#PREFIX#/etc/jupyter"
export JUPYTER_DATA_DIR="#PREFIX#/share/jupyter"
echo "Using $(python --version) from $(which python)"
echo "This is Scientific Python version #PKG_VERSION#"
workdir="$HOME/Documents/scientific-python"
mkdir -p $workdir
pushd $workdir
