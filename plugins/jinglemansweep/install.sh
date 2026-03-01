#!/usr/bin/env bash

declare -r DEST="${CLAUDE_DIR:-$HOME/.claude}"

cp -r skills/* "${DEST}/skills/"
cp -r agents/* "${DEST}/agents/"
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

echo "Cleaned up old skill and agent artefacts"
