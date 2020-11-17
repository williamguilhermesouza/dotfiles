#! /bin/bash
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/neoviminstall.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/neoviminstall.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget  (https://raw.githubusercontent.com/williamguilhermesouza/dotfiles/master/neoviminstall.sh)

# installing neovim
sudo apt install neovim -y
# checking if .config/nvim exists, if not create if
#[ ! -d "~/.config/nvim" ] && mkdir -p ~/.config/nvim
# installing plug for nvim plugin management
sh -c 'curl -fLo "${HOME}"/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# copy nvim files
cp -r .config/nvim $HOME/.config/
