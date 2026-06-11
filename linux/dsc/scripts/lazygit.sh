#!/usr/bin/env bash

LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name)

curl -Lo lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"

tar xf lazygit.tar.gz lazygit

sudo install lazygit /usr/local/bin
