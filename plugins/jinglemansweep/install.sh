#!/usr/bin/env bash

set -euo pipefail

declare -r DEST="${CLAUDE_DIR:-$HOME/.claude}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r SCRIPT_DIR

cp -r "${SCRIPT_DIR}"/skills/* "${DEST}/skills/"

# Only copy agents if the agents directory is non-empty
if compgen -G "${SCRIPT_DIR}/agents/*" > /dev/null 2>&1; then
  cp -r "${SCRIPT_DIR}"/agents/* "${DEST}/agents/"
fi

echo "Installed plugin to ${DEST}"
