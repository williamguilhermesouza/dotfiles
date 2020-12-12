#! /bin/bash
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/goinstall.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/goinstall.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/goinstall.sh)


# Download go from google
wget https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz

# Install tarball
sudo tar -C /usr/local -xzf go1.15.3.linux-amd64.tar.gz

# export GO to path
export PATH=$PATH:/usr/local/go/bin

# add export to bashrc
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc

# check version 
go version
