#!/usr/bin/env bash

set -e

sudo apt install -y \
    neovim

./cli-tools.sh
./wm.sh

./node.sh
./lazygit.sh 
./carapace.sh
./dotnet.sh 
./golang.sh
