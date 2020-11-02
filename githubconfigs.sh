#! /bin/bash
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/githubconfigs.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/githubconfigs.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/githubconfigs.sh)


# config username
git config --global user.name "williamguilhermesouza"

# config email
git config --global user.email "williamguilhermesouza@gmail.com"

# store credentials
git config credential.helper store
