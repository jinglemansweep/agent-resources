#!/usr/bin/env bash

declare -r DEST="${CLAUDE_DIR:-$HOME/.claude}"

cp -r skills/* "${DEST}/skills/"
cp -r agents/* "${DEST}/agents/"
echo "Installed plugin to ${DEST}"
