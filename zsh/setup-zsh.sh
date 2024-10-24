#!/bin/bash

mkdir -p $HOME/.zsh-plugins/

git clone https://github.com/jeffreytse/zsh-vi-mode.git $HOME/.zsh-plugins/.zsh-vi-mode

cp ./zshrc $HOME/.zshrc

echo "please install the following packages before changing shell: zsh-syntax-highlighting, zsh-autosuggestions"
