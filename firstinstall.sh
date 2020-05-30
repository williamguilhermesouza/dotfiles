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
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt install gconf-service fonts-firacode zsh dconf-cli silversearcher-ag nodejs neovim -y
sudo apt install --no-install-recommends yarn
sudo npm install npm@latest -g
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo git clone https://github.com/dracula/zsh.git
sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
sudo ln -s zsh/dracula.zsh-theme ~/.oh-my-zsh/themes
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "~/.oh-my-zsh/themes/spaceship.zsh-theme"
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
[ ! -d "~/.config/nvim" ] && mkdir -p ~/.config/nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
git clone "https://github.com/williamguilhermesouza/dotfiles.git"
cd dotfiles
./installfonts.sh
./symlinkcreation.sh

