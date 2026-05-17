# Product Requirements Document

> Source: `.plans/2026/03/01/09-datetime-handling-fix/prompt.md`

## Project Overview

The jplan plugin has two naming and data-quality issues that need to be fixed. First, the six `jp-persona-*` domain-role skills should be renamed to `role-*` to shorten invocations and align with their purpose as domain-role definitions (all other pipeline skills retain the `jp-` prefix). Second, timestamps written to `state.yaml` and task log files during pipeline execution are fabricated by the LLM rather than obtained from the system clock, producing incorrect dates, times, and durations. Both issues affect usability and auditability of pipeline outputs.

## Goals

- Rename all `jp-persona-*` skills to `role-*` across directory names, file contents, and every reference throughout the codebase.
- Ensure all timestamps written by pipeline skills to `state.yaml`, task log files, and other artifacts reflect actual wall-clock time obtained via shell commands (`date` or equivalent), not LLM-generated values.
- Maintain full backward compatibility of the pipeline -- all skills and agents continue to function correctly after both changes.

## Functional Requirements

### REQ-001: Rename skill directories from `jp-persona-*` to `role-*`

**Description:** Rename the six `jp-persona-*` skill directories under `plugins/jplan/skills/` to use the `role-*` prefix instead.

| Current directory name | New directory name |
|---|---|
| `jp-persona-python` | `role-python` |
| `jp-persona-nodejs` | `role-nodejs` |
| `jp-persona-frontend` | `role-frontend` |
| `jp-persona-devops` | `role-devops` |
| `jp-persona-docs` | `role-docs` |
| `jp-persona-agent-skills` | `role-agent-skills` |

**Acceptance Criteria:**

- [ ] All six directories exist under `plugins/jplan/skills/` with `role-*` names.
- [ ] No `jp-persona-*` directories remain under `plugins/jplan/skills/`.

### REQ-002: Update SKILL.md frontmatter and headings in renamed skills

**Description:** Within each renamed skill's `SKILL.md`, update the `name:` field in the YAML frontmatter and the top-level `# heading` to use the new `role-*` name.

**Acceptance Criteria:**

- [ ] Each `role-*/SKILL.md` has `name: role-<domain>` in its frontmatter.
- [ ] Each `role-*/SKILL.md` has `# role-<domain>` as its top-level heading.
- [ ] No occurrences of `jp-persona-` remain in any of the six renamed `SKILL.md` files.

### REQ-003: Update plugin.json skill list

**Description:** Update `plugins/jplan/plugin.json` to list the skills with their new `role-*` names instead of `jp-persona-*`.

**Acceptance Criteria:**

- [ ] The `skills` array in `plugin.json` contains `role-python`, `role-nodejs`, `role-frontend`, `role-devops`, `role-docs`, `role-agent-skills`.
- [ ] No `jp-persona-*` entries remain in the `skills` array.

### REQ-004: Update jp-worker-dev agent signal table

**Description:** Update the file path references in the signal-matching table in `plugins/jplan/agents/jp-worker-dev.md` to point to the new `role-*` directory names.

**Acceptance Criteria:**

- [ ] All six skill file paths in the signal table reference `plugins/jplan/skills/role-*/SKILL.md`.
- [ ] No `jp-persona-*` paths remain in `jp-worker-dev.md`.

### REQ-005: Update jp-execute skill reference to documentation role

**Description:** The `jp-execute/SKILL.md` invokes `/jp-persona-docs` in Step 9 (Documentation Review). Update this reference to `/role-docs`.

**Acceptance Criteria:**

- [ ] Step 9 of `jp-execute/SKILL.md` references `/role-docs` instead of `/jp-persona-docs`.
- [ ] No occurrences of `jp-persona-` remain in `jp-execute/SKILL.md`.

### REQ-006: Update jp-task-list suggested_role mapping table

**Description:** The `jp-task-list/SKILL.md` contains a table mapping domain keywords to `jp-persona-*` skill names. Update the skill name column to use `role-*` names.

**Acceptance Criteria:**

- [ ] The suggested_role mapping table in `jp-task-list/SKILL.md` uses `role-python`, `role-nodejs`, `role-frontend`, `role-devops`, `role-docs`, `role-agent-skills`.
- [ ] No `jp-persona-*` entries remain in `jp-task-list/SKILL.md`.

### REQ-007: Update README.md references

**Description:** Update any references to `jp-persona-*` skill names or directory paths in `README.md` to use the new `role-*` names.

**Acceptance Criteria:**

- [ ] No occurrences of `jp-persona-` remain in `README.md`.
- [ ] All renamed skill references use `role-*` names.

### REQ-008: Update .agentmap.yaml references

**Description:** Update any references to `jp-persona-*` in `.agentmap.yaml` to use the new `role-*` names.

**Acceptance Criteria:**

- [ ] No occurrences of `jp-persona-` remain in `.agentmap.yaml`.

### REQ-009: Update settings.local.example.json references

**Description:** Update any references to `jp-persona-*` in `settings.local.example.json` to use the new `role-*` names.

**Acceptance Criteria:**

- [ ] No occurrences of `jp-persona-` remain in `settings.local.example.json`.

### REQ-010: Add explicit timestamp instructions to jp-execute skill

**Description:** The `jp-execute/SKILL.md` uses `<ISO 8601 timestamp>` placeholders without specifying how to obtain the actual time. Add an explicit instruction near the top of the Instructions section requiring that all timestamps be obtained by running `date -u +"%Y-%m-%dT%H:%M:%SZ"` via Bash and using the command output. This applies to every location in the skill that writes a timestamp to `state.yaml` or to task log files.

**Acceptance Criteria:**

- [ ] A clear, unambiguous instruction exists in `jp-execute/SKILL.md` (before the first timestamp usage) stating that every `<ISO 8601 timestamp>` must be obtained by running `date -u +"%Y-%m-%dT%H:%M:%SZ"` via the Bash tool and using the returned value.
- [ ] The instruction explicitly prohibits generating, estimating, or fabricating timestamp values.
- [ ] Each YAML template block in the skill that contains `<ISO 8601 timestamp>` references the shell command instruction.

### REQ-011: Add explicit timestamp instructions to jp-summary skill

**Description:** If the `jp-summary/SKILL.md` writes or records any timestamps (e.g. generation time), add the same explicit shell-command requirement as REQ-010.

**Acceptance Criteria:**

- [ ] Any timestamp written by `jp-summary` is obtained via shell command.
- [ ] If the skill does not write timestamps, no changes are needed (this requirement is satisfied by default).

### REQ-012: Add explicit timestamp instructions to task log template

**Description:** The task log template in `jp-execute/SKILL.md` (Step 5g) includes `Started` and `Finished` fields. Ensure the instructions make clear these values must come from the shell command captured at task start (Step 5c) and task completion (Step 5g), not generated at log-writing time.

**Acceptance Criteria:**

- [ ] The task log template instructions in Step 5g reference the `started_at` value recorded in Step 5c and the current time obtained via shell command for the `Finished` field.
- [ ] No timestamp in task logs can be a fabricated value.

## Non-Functional Requirements

### REQ-013: No stale references after rename

**Category:** Maintainability

**Description:** After the rename, a full-text search of the repository for `jp-persona-` must return zero results outside of historical `.plans/` artifacts (which are immutable records of past phases and must not be modified).

**Acceptance Criteria:**

- [ ] Running `grep -r "jp-persona-" --include="*.md" --include="*.json" --include="*.yaml" --include="*.yml"` against the repository root returns only matches in `.plans/` directories (historical artifacts) or returns no matches at all.

### REQ-014: Timestamp accuracy

**Category:** Reliability

**Description:** Timestamps in `state.yaml` and task log files must reflect actual wall-clock time with reasonable accuracy (within a few seconds of the actual event).

**Acceptance Criteria:**

- [ ] Timestamps in newly generated `state.yaml` and task logs reflect the system clock at the time of the event, not fabricated or estimated values.
- [ ] Duration between `started_at` and `finished_at` for a task is consistent with actual execution time (not sub-second for tasks that take minutes).

## Technical Constraints and Assumptions

### Constraints

- Directory renames must use `git mv` to preserve version history.
- The `Bash` tool must be listed in `allowed-tools` for any skill that needs to run `date` commands (already the case for `jp-execute`).
- Historical `.plans/` artifacts from completed phases must not be modified -- they are immutable records.

### Assumptions

- The `date` command is available on all target systems (standard on Linux/macOS).
- The `-u` flag produces UTC output on all target systems.
- No external tools or CI configurations reference the `jp-persona-*` names (references are limited to this repository).

## Scope

### In Scope

- Renaming the six `jp-persona-*` skill directories and updating all internal references.
- Adding explicit timestamp-via-shell-command instructions to `jp-execute/SKILL.md`.
- Updating `plugin.json`, `jp-worker-dev.md`, `jp-task-list/SKILL.md`, `jp-execute/SKILL.md`, `README.md`, `.agentmap.yaml`, and `settings.local.example.json`.

### Out of Scope

- Modifying historical `.plans/` artifacts (completed phase state files, logs, etc.).
- Renaming any skills that do not use the `jp-persona-` prefix.
- Changing the `jp-` prefix on non-persona skills.
- Modifying the `install.sh` script (unless it contains `jp-persona-` references).
- Adding new skills or agents.

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Version control | `git mv` | Preserve rename history for skill directories |
| Timestamp source | `date -u +"%Y-%m-%dT%H:%M:%SZ"` | Standard POSIX utility, produces ISO 8601 UTC timestamps |
