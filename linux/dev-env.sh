#!/usr/bin/env bash

if [[ -n "${BASH_SOURCE[0]-}" ]]; then
    SCRIPT_PATH="${BASH_SOURCE[0]}"
    IS_SOURCED=0
    if [[ "${BASH_SOURCE[0]-}" != "${0-}" ]]; then
        IS_SOURCED=1
    fi
elif [[ -n "${ZSH_VERSION-}" ]]; then
    SCRIPT_PATH="${(%):-%N}"
    IS_SOURCED=0
    if [[ "${SCRIPT_PATH}" != "${0-}" ]]; then
        IS_SOURCED=1
    fi
else
    SCRIPT_PATH="$0"
    IS_SOURCED=0
fi

SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPTS_DIR="${REPO_ROOT}/linux/scripts"

export DEV_ENV="${REPO_ROOT}"

case ":${PATH}:" in
    *":${SCRIPTS_DIR}:"*) ;;
    *) export PATH="${PATH}:${SCRIPTS_DIR}" ;;
esac

echo "DEV_ENV=${DEV_ENV}"
echo "Added to PATH (if missing): ${SCRIPTS_DIR}"

if [[ "${IS_SOURCED}" == "0" ]]; then
    echo "Tip: run 'source ${SCRIPT_DIR}/dev-env.sh' to keep DEV_ENV and PATH in the current shell."
fi
