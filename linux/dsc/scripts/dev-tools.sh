#!/usr/bin/env bash

set -e

sudo apt install -y \
    neovim \
    fd-find \
    fzf \
    ripgrep \
    jq \
    tidy \
    bat \
    sway \
    waybar

# ========== NodeJs ==========
# Baixar e instalar o nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Carregar o nvm sem precisar reiniciar o shell
\. "$HOME/.nvm/nvm.sh"

# Baixar e instalar o Node.js:
nvm install 24

# Verifique a versão do Node.js:
# node -v # Deve exibir "v24.16.0".

# Verificar a versão do npm:
# npm -v # Deve imprimir "11.13.0".
# ============================
#
# ========== LazyGit ==========
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name)

curl -Lo lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"

tar xf lazygit.tar.gz lazygit

sudo install lazygit /usr/local/bin
# ============================
#
# ========= Carapace ========
curl -L \
  https://github.com/carapace-sh/carapace-bin/releases/latest/download/carapace-bin_linux_amd64.tar.gz \
  | tar -xz

sudo install carapace /usr/local/bin
# ============================
#
# ====== dotnet =======
sudo apt install -y \
    dotnet-sdk-10.0
# =====================
#
# ====== Golang ========

# 1. Fetch latest Go version
VERSION=$(curl -s https://go.dev/dl/?mode=json | grep -o '"version": "[^"]*' | head -n 1 | cut -d'"' -f4)

# 2. Detect Architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi
if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi

OS=$(uname | tr '[:upper:]' '[:lower:]')

# 3. Download tarball
URL="https://go.dev/dl/${VERSION}.${OS}-${ARCH}.tar.gz"
curl -sSLO "$URL"

# 4. Extract and Install to /usr/local/go
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${VERSION}.${OS}-${ARCH}.tar.gz"
rm "${VERSION}.${OS}-${ARCH}.tar.gz"

# 5. Configure Shell Profile Environment
SHELL_PROFILE="$HOME/.bashrc"
if [ "$SHELL" = "/bin/zsh" ]; then SHELL_PROFILE="$HOME/.zshrc"; fi

if ! grep -q '/usr/local/go/bin' "$SHELL_PROFILE"; then
    echo 'export GOPATH=$HOME/go' >> "$SHELL_PROFILE"
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> "$SHELL_PROFILE"
fi
# =======================
