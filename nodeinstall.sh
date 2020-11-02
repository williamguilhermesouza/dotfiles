#! /bin/bash
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/nodeinstall.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/nodeinstall.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/nodeinstall.sh)
# keys for node 
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
# installing node
sudo apt install nodejs -y
# installing yarn 
sudo npm i -g yarn
# updating npm
sudo npm install npm@latest -g