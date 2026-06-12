#!/usr/bin/env bash

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
