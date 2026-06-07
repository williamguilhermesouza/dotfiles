#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"

docker run --rm -it \
    -v "${REPO_ROOT}:/dotfiles" \
    dotfiles-test
