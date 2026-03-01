# Product Requirements Document

> Source: `.plans/2026/03/01/01-various-fixes/prompt.md`

## Project Overview

This phase delivers a set of targeted fixes and renames to the jinglemansweep plugin. It enhances the PRD review skill to interview users about each requirement, renames the validate skill for clarity, adds model frontmatter to agent definitions, and standardises domain skill naming from `jms-skill-*` to `jms-role-*` (with a special case for the skill-authoring skill).

## Goals

- Improve the PRD review workflow by giving users explicit control over each requirement before finalising
- Make the validate skill name reflect that it validates task outputs (`jms-plan-task-validate`)
- Enable model selection in agent definitions via frontmatter
- Establish a consistent `jms-role-*` naming convention for domain/role skills, distinct from `jms-plan-*` pipeline skills

## Functional Requirements

### REQ-001: PRD Review Requirement Interview

**Description:** The `jms-plan-prd-review` skill must interview the user about each functional and non-functional requirement in the PRD individually, giving the user the opportunity to approve, update, or remove each requirement before the review verdict is determined.

**Acceptance Criteria:**

- [ ] After reading the PRD, the skill presents each `REQ-NNN` to the user one at a time (or in small batches) with options to approve, edit, or remove
- [ ] If the user chooses to edit a requirement, they can provide updated text and the PRD is modified accordingly
- [ ] If the user chooses to remove a requirement, it is deleted from `prd.md` and subsequent requirement IDs are renumbered to remain sequential
- [ ] The interview step occurs after the coverage assessment (Step 3) but before the verdict determination (Step 6), so the user can act on coverage gaps
- [ ] After the interview is complete, the skill continues with its existing evaluation and verdict logic using the updated requirements

### REQ-002: Rename jms-plan-validate to jms-plan-task-validate

**Description:** Rename the `jms-plan-validate` skill directory and all internal/external references to `jms-plan-task-validate` to clarify that it validates task outputs rather than the plan itself.

**Acceptance Criteria:**

- [ ] The skill directory is renamed from `plugins/jinglemansweep/skills/jms-plan-validate/` to `plugins/jinglemansweep/skills/jms-plan-task-validate/`
- [ ] The SKILL.md frontmatter `name` field is updated to `jms-plan-task-validate`
- [ ] The SKILL.md heading and usage examples reference `jms-plan-task-validate`
- [ ] `plugins/jinglemansweep/plugin.json` skill list entry is updated
- [ ] `plugins/jinglemansweep/skills/jms-plan-execute/SKILL.md` references are updated (all occurrences of `/jms-plan-validate`)
- [ ] `plugins/jinglemansweep/skills/jms-plan-fix/SKILL.md` reference is updated
- [ ] `README.md` references are updated (directory tree and skill descriptions)
- [ ] `.agentmap.yaml` reference is updated
- [ ] No stale references to `jms-plan-validate` remain in any active plugin file (`.plans/` log files are excluded from this check)

### REQ-003: Add Model Frontmatter to Agent Definitions

**Description:** Add a `model` field to agent YAML frontmatter to specify which Claude model the agent should use. The `jms-developer` agent must specify `model: opus`.

**Acceptance Criteria:**

- [ ] `plugins/jinglemansweep/agents/jms-developer.md` has `model: opus` in its YAML frontmatter
- [ ] `plugins/jinglemansweep/agents/jms-planner.md` has `model: opus` in its YAML frontmatter (planner also benefits from the strongest model)
- [ ] The frontmatter remains valid YAML with `name`, `description`, and `model` fields

### REQ-004: Rename Domain Skills from jms-skill-* to jms-role-*

**Description:** Rename all domain skill directories and references from the `jms-skill-` prefix to the `jms-role-` prefix to better reflect that these are role-based domain skills, not pipeline skills.

**Acceptance Criteria:**

- [ ] `jms-skill-python` directory and references renamed to `jms-role-python`
- [ ] `jms-skill-nodejs` directory and references renamed to `jms-role-nodejs`
- [ ] `jms-skill-frontend` directory and references renamed to `jms-role-frontend`
- [ ] `jms-skill-devops` directory and references renamed to `jms-role-devops`
- [ ] `jms-skill-docs` directory and references renamed to `jms-role-docs`
- [ ] Each renamed skill's SKILL.md frontmatter `name` field and heading are updated
- [ ] `plugins/jinglemansweep/plugin.json` skill list entries are updated for all five skills
- [ ] `plugins/jinglemansweep/agents/jms-developer.md` routing table paths are updated
- [ ] `plugins/jinglemansweep/skills/jms-plan-task-breakdown/SKILL.md` domain skill table is updated (note: use the new validate skill name from REQ-002)
- [ ] `README.md` directory tree and skill descriptions are updated
- [ ] `.agentmap.yaml` references are updated
- [ ] No stale references to `jms-skill-python`, `jms-skill-nodejs`, `jms-skill-frontend`, `jms-skill-devops`, or `jms-skill-docs` remain in any active plugin file

### REQ-005: Rename jms-skill-skills to jms-role-agent-skills

**Description:** The skill-authoring domain skill receives a different target name than the standard `jms-role-` rename pattern. Instead of becoming `jms-role-skills`, it must be renamed to `jms-role-agent-skills` to avoid the redundant "role-skills" naming.

**Acceptance Criteria:**

- [ ] `jms-skill-skills` directory renamed to `jms-role-agent-skills` (not `jms-role-skills`)
- [ ] SKILL.md frontmatter `name` field updated to `jms-role-agent-skills`
- [ ] SKILL.md heading updated to `jms-role-agent-skills`
- [ ] `plugins/jinglemansweep/plugin.json` skill list entry updated
- [ ] `plugins/jinglemansweep/agents/jms-developer.md` routing table path updated for skill authoring domain
- [ ] `plugins/jinglemansweep/skills/jms-plan-task-breakdown/SKILL.md` domain skill table entry updated
- [ ] `README.md` references updated
- [ ] `.agentmap.yaml` reference updated
- [ ] No stale references to `jms-skill-skills` remain in any active plugin file

## Non-Functional Requirements

### REQ-006: No Broken Cross-References

**Category:** Maintainability

**Description:** After all renames are applied, every skill and agent file must have internally consistent references. No active file outside `.plans/` should reference a pre-rename skill name.

**Acceptance Criteria:**

- [ ] A grep for `jms-plan-validate` (without `task-` following) in active plugin files returns zero matches (excluding `.plans/` history)
- [ ] A grep for `jms-skill-` in active plugin files returns zero matches (excluding `.plans/` history)
- [ ] All paths referenced in `jms-developer.md` routing table resolve to existing SKILL.md files
- [ ] All skill names in `plugin.json` correspond to existing skill directories

## Technical Constraints and Assumptions

### Constraints

- All changes are within the `plugins/jinglemansweep/` directory, `README.md`, and `.agentmap.yaml`
- The `install.sh` script must remain functional after renames
- Existing `.plans/` history files (logs, summaries, task files from prior phases) are not updated -- they are historical records

### Assumptions

- The `jms-plan-prd-review` skill is installed locally at `~/.claude/skills/jms-plan-prd-review/` and changes to the plugin source will be installed via `install.sh`
- The `model` frontmatter field is supported by the Claude Code agent framework for agent definitions
- Git will track directory renames as rename operations when files are moved with `git mv`

## Scope

### In Scope

- Modifying `jms-plan-prd-review` SKILL.md to add the requirement interview workflow
- Renaming `jms-plan-validate` to `jms-plan-task-validate` (directory + all references)
- Adding `model` frontmatter to agent files
- Renaming 5 domain skills from `jms-skill-*` to `jms-role-*` (directories + all references)
- Renaming `jms-skill-skills` to `jms-role-agent-skills` (directory + all references)
- Updating `README.md`, `.agentmap.yaml`, `plugin.json`, and cross-referencing skill files

### Out of Scope

- Updating historical `.plans/` log files, summaries, or task files from prior phases
- Changes to the `agentmap` plugin
- Changes to `marketplace.json`
- Adding new skills or agents
- Modifying skill behaviour beyond what is specified (e.g. no changes to `jms-plan-execute` logic, only reference updates)

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Files | Markdown, YAML, JSON | Existing formats used throughout the project (specified by project) |
| VCS | Git (`git mv`) | Preserve rename history for directory renames (specified by project) |
