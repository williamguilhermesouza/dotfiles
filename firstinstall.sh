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
sudo apt install fonts-firacode zsh dconf-cli silversearcher-ag neovim -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/dracula/gnome-terminal
cd gnome-terminal
./install.sh
cd ..
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
[ ! -d "~/.config/nvim" ] && mkdir -p ~/.config/nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
git clone "https://github.com/williamguilhermesouza/dotfiles.git"
cd dotfiles
./installfonts.sh
./symlinkcreation.sh

