#!/bin/bash

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
echo "DEV_ENV=$DEV_ENV" >> ~/.bashrc
