#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/firstinstall.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/firstinstall.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/firstinstall.sh)
# install.sh
# keys for node 
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
# installing dependencies
sudo apt install gconf-service fonts-firacode zsh dconf-cli silversearcher-ag nodejs neovim -y
# installing yarn 
sudo npm i -g yarn
# updating npm
sudo npm install npm@latest -g
# installing oh-my-zsh
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# installing spaceship theme
sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
ln -s "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/themes/spaceship.zsh-theme"
# changing the theme in .zshrc to spaceship
sed -i "s/ZSH_THEME=.*/ZSH_THEME=\"spaceship\"/g" ~/.zshrc
# cloning the repo 
git clone "https://github.com/williamguilhermesouza/dotfiles.git"
cd dotfiles
# puting spaceship conf in .zshrc
cat spaceshipconf.txt >> .zshrc
# installing zinit to install plugins
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
# copying plugins to .zshrc
cat zshplugins.txt >> .zshrc
# checking if .config/nvim exists, if not create if
[ ! -d "~/.config/nvim" ] && mkdir -p ~/.config/nvim
# installing plug for nvim plugin management
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# installing font firacode to .local folder
./installfonts.sh
# creating symlinks of conf files 
./symlinkcreation.sh


