#! /bin/bash

# downloading sweet dark theme
sudo curl "https://www.gnome-look.org/p/1253385/startdownload?file_id=1590430654&file_name=Sweet-Dark.tar.xz&file_type=application/x-xz&file_size=251452" --create-dirs -o ~/.themes

# extracting the theme
sudo tar -xf ~/.themes/Sweet-Dark.tar.xz

# installing breeze cursor and geary email
sudo dnf install breeze cursor-theme geary -y

# installing node
curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
sudo dnf install nodejs -y

# installing yarn 
sudo npm install -g yarn

# installing typescript 
sudo npm install -g typescript

# RPM repositories for postgres
sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/F-32-x86_64/pgdg-fedora-repo-latest.noarch.rpm

# client packages and server
sudo dnf install postgresql12 postgresql12-server -y
/usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl enable postgresql-12
sudo systemctl start postgresql-12

# install pgadmin4
sudo dnf -y install pgadmin4 -y

# install spotify
sudo flatpak install flathub com.spotify.Client -y

# install steam
sudo flatpak install flathub com.valvesoftware.Steam -y

# install snapd
sudo dnf install snapd -y

# install insomnia using snapd
sudo snap install insomnia

# installing make
sudo dnf install make -y

# clonning tiling for pop
git clone https://github.com/pop-os/shell.git
cd shell
sh rebuild.sh

# installing expo cli for react-native
sudo npm installl expo-cli --global

# installing nestJS cli 
sudo npm i -g @nestjs/cli

# install kitty terminal
sudo dnf install kitty -y

# to configure kitty with fira code
echo 'font_family   FiraCode' >> $HOME/.config/kitty/kitty.conf

# configuring postgresql
#sudo su - postgres

# entering psql console
#psql

# altering postgresuser pass to 123
#ALTER USER postgres WITH PASSWORD '123';
#exit
#exit

# configuring pg_hba and postgresql.conf
#sudo echo 'host all all all md5' >> /var/lib/pgsql/12/data/pg_hba.conf
#sed -i "s/#listen_addresses='127.0.0.1'/listen_addresses='*'/g" /var/lib/pgsql/12/data/postgresql.conf
#sudo systemctl restart postgresql-12

#configuring pgadmin4
#sudo systemctl start httpd && sudo systemctl enable httpd
#sudo cp /etc/httpd/conf.d/pgadmin4.conf.sample /etc/httpd/conf.d/pgadmin4.conf
#sudo mkdir -p /var/lib/pgadmin4/ /var/log/pgadmin4/
#cd ..
#cat ./fedorapgadminconfig_distro.txt >> /usr/lib/python3.8/site-packages/pgadmin4-web/config_distro.py
#sudo python3 /usr/lib/python3.8/site-packages/pgadmin4-web/setup.py
#sudo chown -R apache:apache /var/lib/pgadmin4 /var/log/pgadmin4
#sudo systemctl restart httpd
