#!/bin/bash

git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

cp ./tmux.conf $HOME/.tmux.conf

/bin/bash $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
