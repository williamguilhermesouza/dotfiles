#!/usr/bin/env bash
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/githubconfigs.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/githubconfigs.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/githubconfigs.sh)

# get basic tools
apt-get update && apt-get install -y \
    git \
    curl \
    zsh \
    sudo

# git configure
read -rp "Enter your git username: " username
read -rp "Enter your git email: " email
git config --global user.name $username
git config --global user.email $email

# pull the configs
git clone https://github.com/williamguilhermesouza/dotfiles.git

# set dev env
source ./dotfiles/linux/dev-env.sh
