#! /bin/bash
# keys for node 
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
# installing node
sudo apt install nodejs -y
# installing yarn 
sudo npm i -g yarn
# updating npm
sudo npm install npm@latest -g