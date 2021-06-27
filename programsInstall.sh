#! /bin/bash

#install vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg

sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/

sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

rm -f packages.microsoft.gpg

sudo apt install apt-transport-https -y

sudo apt update

sudo apt install code -y

# install spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 

echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get update && sudo apt-get install spotify-client -y

# balena etcher
wget https://github.com/balena-io/etcher/releases/download/v1.5.120/balena-etcher-electron-1.5.120-linux-x64.zip?d_id=81577739-3519-4108-bcd3-d51224667665R
unzip unzip balena-etcher-electron-1.5.120-linux-x64.zip\?d_id=81577739-3519-4108-bcd3-d51224667665R
rm balena-etcher-electron-1.5.120-linux-x64.zip\?d_id=81577739-3519-4108-bcd3-d51224667665R 
