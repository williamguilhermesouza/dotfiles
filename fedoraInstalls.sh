#! /bin/bash

# downloading sweet dark theme
sudo curl "https://www.gnome-look.org/p/1253385/startdownload?file_id=1590430654&file_name=Sweet-Dark.tar.xz&file_type=application/x-xz&file_size=251452" --create-dirs -o ~/.themes

# extracting the theme
sudo tar -xf ~/.themes/Sweet-Dark.tar.xz

# installing breeze cursor and geary email
sudo dnf install breeze cursor-theme geary -y

# installing node
curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -

# installing yarn 
sudo npm install -g yarn

# installing typescript 
sudo npm install -g typescript

# install spotify
sudo flatpak install flathub com.spotify.Client

# install steam
sudo flatpak install flathub com.valvesoftware.Steam


