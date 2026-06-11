#!/usr/bin/env bash

curl -L \
  https://github.com/carapace-sh/carapace-bin/releases/latest/download/carapace-bin_linux_amd64.tar.gz \
  | tar -xz

sudo install carapace /usr/local/bin
