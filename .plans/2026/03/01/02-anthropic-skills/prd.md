# Product Requirements Document

> Source: `.plans/2026/03/01/01-anthropic-skills/prompt.md`

## Project Overview

Enhance the `jms-execute` pipeline orchestrator to recognise when a task involves creating or modifying Claude Code skill files (SKILL.md) and delegate those tasks using Anthropic's `skill-creator` skill. This allows the pipeline to produce higher-quality skills by leveraging the skill-creator's structured authoring guidance, progressive-disclosure patterns, and description-writing best practices.

## Goals

- Enable the jms-execute orchestrator to automatically detect skill-authoring tasks and route them through the `skill-creator` skill's guidance.
- Preserve backward compatibility — tasks that do not involve skill files continue to be routed through existing role agents unchanged.

## Functional Requirements

### REQ-001: Add a Skills Role Agent Entry

**Description:** Add a new `skills` entry to the `agents` section of the jms-execute orchestrator configuration. This entry maps to a new `jms-role-skills` agent and includes signal keywords that identify skill-authoring tasks.

**Acceptance Criteria:**

- [ ] A `skills` key exists in the `agents` block of `jms-execute/SKILL.md` with agent name `jms-role-skills`.
- [ ] The signals list includes keywords that reliably identify skill work: `["SKILL.md", "skill", "skills/", "agent skill", "skill-creator"]`.
- [ ] The `skills` entry appears before the `general` fallback entry in the agent list.

### REQ-002: Create the jms-role-skills Agent Definition

**Description:** Create a new agent file `plugins/jinglemansweep/agents/jms-role-skills.md` that acts as the role agent for skill-authoring tasks. This agent instructs the executor to read and follow the `skill-creator` SKILL.md when working on skill files, combining the skill-creator's authoring guidance with the jms pipeline's task-execution conventions.

**Acceptance Criteria:**

- [ ] The file `plugins/jinglemansweep/agents/jms-role-skills.md` exists and follows the existing agent Markdown format used by other `jms-role-*` agents.
- [ ] The agent definition instructs the executor to consult the `skill-creator` skill's guidance (located at the Anthropic marketplace skills path) when creating or modifying SKILL.md files.
- [ ] The agent inherits the same tool access pattern as other role agents (Read, Edit, Write, Bash, Glob, Grep).
- [ ] The agent instructs adherence to the project's existing skill conventions (one SKILL.md per skill directory, YAML frontmatter with name and description, etc.) as defined in the project CLAUDE.md.

### REQ-003: Update Role Selection Logic Documentation

**Description:** Update the role-mapping table in Step 5d of `jms-execute/SKILL.md` to include the new `skills` role, so the orchestrator's documented selection logic covers skill-authoring tasks.

**Acceptance Criteria:**

- [ ] The role-mapping table in Step 5d includes a row mapping `suggested_role` value `skills` to agent `jms-role-skills`.
- [ ] The signal-matching documentation in Step 5d references the `skills` agent entry from the orchestrator configuration for override decisions.

## Non-Functional Requirements

### REQ-004: Backward Compatibility

**Category:** Maintainability

**Description:** The change must not alter routing behaviour for any existing task type. Tasks that previously routed to python, nodejs, devops, frontend, docs, or general agents must continue to do so.

**Acceptance Criteria:**

- [ ] No existing signal keywords are removed or reassigned from existing agent entries.
- [ ] The `general` agent remains the last entry and continues to act as the fallback when no other role matches.

### REQ-005: Convention Consistency

**Category:** Maintainability

**Description:** All new files and modifications follow the project's established conventions for agent definitions, skill structure, and documentation style.

**Acceptance Criteria:**

- [ ] The new agent file uses the same Markdown structure and frontmatter pattern as existing `jms-role-*` agents.
- [ ] Updates to `jms-execute/SKILL.md` maintain the existing document structure, formatting, and style.

## Technical Constraints and Assumptions

### Constraints

- The `skill-creator` skill is installed via the Anthropic marketplace at `~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/skill-creator/SKILL.md`. The agent definition must reference this path or instruct the executor to locate it dynamically.
- The `jms-execute` orchestrator processes tasks sequentially and delegates to one role agent per task — the skills agent follows this same pattern.
- No external dependencies may be added.

### Assumptions

- The Anthropic `skill-creator` skill will remain installed at the marketplace path and its SKILL.md interface is stable.
- Skill-authoring tasks in `tasks.yaml` will use `suggested_role: skills` or will be identifiable by signal keywords in their description and files_affected fields.

## Scope

### In Scope

- Adding the `skills` agent entry to the jms-execute orchestrator configuration.
- Creating the `jms-role-skills` agent definition file.
- Updating the role-mapping documentation in jms-execute Step 5d.

### Out of Scope

- Running the skill-creator's full eval/benchmark loop during pipeline execution — the agent only uses the authoring guidance, not the iterative testing workflow.
- Description optimization via `run_loop.py` — this is a separate manual step outside the pipeline.
- Modifying any other existing role agents or pipeline skills.
- Changes to the Anthropic skill-creator skill itself.

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Agent definition | Markdown | Specified by project convention — agents are single `.md` files |
| Skill configuration | YAML (embedded in SKILL.md) | Specified by existing jms-execute structure |
