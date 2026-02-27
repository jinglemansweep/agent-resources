#!/usr/bin/env bash

declare -r DEST="${CLAUDE_DIR:-$HOME/.claude}"

cp -r skills/* "${DEST}/skills/"
mkdir -p "${DEST}/agentmap/"
cp example.agentmap.yaml README.md "${DEST}/agentmap/"
echo "Installed plugin to ${DEST}"
