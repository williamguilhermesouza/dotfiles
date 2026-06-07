#!/usr/bin/env bash
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/config-dev.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/config-dev.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/config-dev.sh)
#
# Sets basic dev env
echo "Installing basic tools..."
./scripts/basic-tools.sh
echo "Installing dev tools"
./scripts/dev-tools.sh
echo "Configuring git"
./scripts/git-config.sh
