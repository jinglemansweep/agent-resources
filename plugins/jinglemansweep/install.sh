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

# Clean up old skill directories renamed in v0.4.0
rm -rf "${DEST}/skills/jms-init"
rm -rf "${DEST}/skills/jms-phase-new"
rm -rf "${DEST}/skills/jms-plan"
rm -rf "${DEST}/skills/jms-prd-review"
rm -rf "${DEST}/skills/jms-task-breakdown"
rm -rf "${DEST}/skills/jms-task-review"
rm -rf "${DEST}/skills/jms-execute"
rm -rf "${DEST}/skills/jms-validate"
rm -rf "${DEST}/skills/jms-code-review"
rm -rf "${DEST}/skills/jms-fix"
rm -rf "${DEST}/skills/jms-summary"

# Clean up old role agent files replaced by jms-developer in v0.4.0
rm -f "${DEST}/agents/jms-role-python.md"
rm -f "${DEST}/agents/jms-role-nodejs.md"
rm -f "${DEST}/agents/jms-role-frontend.md"
rm -f "${DEST}/agents/jms-role-devops.md"
rm -f "${DEST}/agents/jms-role-docs.md"
rm -f "${DEST}/agents/jms-role-skills.md"
rm -f "${DEST}/agents/jms-role-general.md"

# Clean up old skill directories renamed in current phase
rm -rf "${DEST}/skills/jms-plan-validate"
rm -rf "${DEST}/skills/jms-skill-python"
rm -rf "${DEST}/skills/jms-skill-nodejs"
rm -rf "${DEST}/skills/jms-skill-frontend"
rm -rf "${DEST}/skills/jms-skill-devops"
rm -rf "${DEST}/skills/jms-skill-docs"
rm -rf "${DEST}/skills/jms-skill-skills"

# Clean up planning skills extracted to the jplan plugin
rm -rf "${DEST}/skills/jms-plan-init"
rm -rf "${DEST}/skills/jms-plan-phase-new"
rm -rf "${DEST}/skills/jms-plan-prd"
rm -rf "${DEST}/skills/jms-plan-prd-review"
rm -rf "${DEST}/skills/jms-plan-task-breakdown"
rm -rf "${DEST}/skills/jms-plan-task-review"
rm -rf "${DEST}/skills/jms-plan-execute"
rm -rf "${DEST}/skills/jms-plan-task-validate"
rm -rf "${DEST}/skills/jms-plan-code-review"
rm -rf "${DEST}/skills/jms-plan-fix"
rm -rf "${DEST}/skills/jms-plan-summary"
rm -rf "${DEST}/skills/jms-plan-workflow"

# Clean up planning agents extracted to the jplan plugin
rm -f "${DEST}/agents/jms-planner.md"
rm -f "${DEST}/agents/jms-developer.md"

# Clean up jms-role-* skill directories moved to the jplan plugin
rm -rf "${DEST}/skills/jms-role-python"
rm -rf "${DEST}/skills/jms-role-nodejs"
rm -rf "${DEST}/skills/jms-role-frontend"
rm -rf "${DEST}/skills/jms-role-devops"
rm -rf "${DEST}/skills/jms-role-docs"
rm -rf "${DEST}/skills/jms-role-agent-skills"

echo "Cleaned up old skill and agent artefacts"
