# install fira-code font, kitty terminal, neovim and wget
sudo pacman -S ttf-fira-code 
sudo pacman -S kitty
sudo pacman -S neovim
sudo pacman -S wget
# install nodejs
sudo pacman -S nodejs
#install yarn
sudo npm i -g yarn@latest

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# download dracula for kitty
wget https://github.com/dracula/kitty/archive/master.zip
# unzip
unzip master.zip
cd kitty-master
# copying files to kitty
cp dracula.conf diff.conf ~/.config/kitty/
echo "include dracula.conf" >> ~/.config/kitty/kitty.conf

#spaceship theme install
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# change theme in .zshrc
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

# neovim
# checking if .config/nvim exists, if not create if
[ ! -d "~/.config/nvim" ] && mkdir -p ~/.config/nvim
# installing plug for nvim plugin management
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'




