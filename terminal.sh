#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/terminal.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/terminal.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/terminal.sh)

# installing dependencies
sudo apt install git zsh gconf-service fonts-firacode dconf-cli silversearcher-ag -y

# installing oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# installing spaceship theme
zsh -c "$(git clone https://github.com/denysdovhan/spaceship-prompt.git \"$HOME/.oh-my-zsh/custom/themes/spaceship-prompt\")"
zsh -c "$(ln -s \"$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme\" \"$HOME/.oh-my-zsh/themes/spaceship.zsh-theme\")"
# changing the theme in .zshrc to spaceship
sed -i "s/ZSH_THEME=.*/ZSH_THEME=\"spaceship\"/g" ~/.zshrc
# cloning the repo 
git clone "https://github.com/williamguilhermesouza/dotfiles.git"
cd dotfiles
# puting spaceship conf in .zshrc
cat spaceshipconf.txt >> ~/.zshrc
# installing zinit to install plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
# copying plugins to .zshrc
cat zshplugins.txt >> ~/.zshrc
