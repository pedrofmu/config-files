#!/bin/bash

mkdir -p $HOME/.zsh-plugins/

git clone https://github.com/jeffreytse/zsh-vi-mode.git $HOME/.zsh-plugins/zsh-vi-mode

cp ./zshrc $HOME/.zshrc

echo "please install the following packages before changing shell: zsh-syntax-highlighting, zsh-autosuggestions"
echo "it is also recomendable to install: 'exa, deno, distro-box, atuin and bat'\n if you dont want to use them make sure to change .zshrc acordingly"
