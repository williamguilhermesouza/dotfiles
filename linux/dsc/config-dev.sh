#!/usr/bin/env bash
#
echo "Installing basic tools..."
./scripts/basic-tools.sh
echo "Installing dev tools"
./scripts/dev-tools.sh
echo "Configuring git"
./scripts/git-config.sh
