#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

link_safe() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "${target}")"

  if [[ -L "${target}" ]] && [[ "$(readlink "${target}")" == "${source}" ]]; then
    echo "Already linked: ${target} -> ${source}"
    return
  fi

  if [[ -e "${target}" || -L "${target}" ]]; then
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    mv "${target}" "${backup}"
    echo "Backed up existing target: ${target} -> ${backup}"
  fi

  ln -s "${source}" "${target}"
  echo "Linked: ${target} -> ${source}"
}

link_safe "${REPO_ROOT}/nvim" "${HOME}/.config/nvim"
link_safe "${REPO_ROOT}/ideavim/.ideavimrc" "${HOME}/.ideavimrc"
link_safe "${REPO_ROOT}/vsvim/.vsvimrc" "${HOME}/.vsvimrc"

echo "Done."
