#! /bin/bash

# install zsh
sudo dnf install zsh -y

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install dracula for gnome-terminal
git clone https://github.com/dracula/gnome-terminal
cd gnome-terminal
./install.sh
cd ..

# install firacode font
sudo dnf install fira-code-fonts -y

# install spaceship theme
sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "/home/william/.oh-my-zsh/custom/themes/spaceship-prompt"
sudo ln -s "/home/william/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "/home/william/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

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

# installing neovim
sudo dnf install neovim -y

# checking if .config/nvim exists, if not create if
[ ! -d "~/.config/nvim" ] && mkdir -p ~/.config/nvim

# installing plug for nvim plugin management
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# installing font firacode to .local folder
./installfonts.sh

# creating symlinks of conf files 
./symlinkcreation.sh
