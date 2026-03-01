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

echo "Installed jplan plugin to ${DEST}"

# Clean up old jp-plan-* skill directories renamed in current phase
rm -rf "${DEST}/skills/jp-plan-code-review"
rm -rf "${DEST}/skills/jp-plan-execute"
rm -rf "${DEST}/skills/jp-plan-fix"
rm -rf "${DEST}/skills/jp-plan-init"
rm -rf "${DEST}/skills/jp-plan-new"
rm -rf "${DEST}/skills/jp-plan-prd"
rm -rf "${DEST}/skills/jp-plan-prd-review"
rm -rf "${DEST}/skills/jp-plan-summary"
rm -rf "${DEST}/skills/jp-plan-task-breakdown"
rm -rf "${DEST}/skills/jp-plan-task-review"
rm -rf "${DEST}/skills/jp-plan-task-validate"
rm -rf "${DEST}/skills/jp-plan-workflow"

# Clean up old agent files renamed in current phase
rm -f "${DEST}/agents/jp-developer.md"

echo "Cleaned up old skill and agent artefacts"
