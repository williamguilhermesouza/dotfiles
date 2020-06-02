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

# RPM repositories for postgres
sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/F-32-x86_64/pgdg-fedora-repo-latest.noarch.rpm

# client packages and server
sudo dnf install postgresql12 postgresql12-server -y

# install pgadmin4
sudo dnf -y install pgadmin4 -y

# install spotify
sudo flatpak install flathub com.spotify.Client -y

# install steam
sudo flatpak install flathub com.valvesoftware.Steam -y

# install snapd
sudo dnf install snapd -y

# install insomnia using snapd
sudo snap install insomnia -y

