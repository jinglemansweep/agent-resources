# Product Requirements Document

> Source: `.plans/2026/03/01/06-separate-plan-plugin/prompt.md`

## Project Overview

Extract the planning pipeline skills and planner agent from the `jinglemansweep` plugin into a new standalone plugin called `jplan`. All moved skills and agents adopt the `jp-` prefix (replacing `jms-plan-`). Additionally, enhance the execution pipeline to enforce quality gates before offering PR creation and to enable auto-merge on created PRs.

## Goals

- Establish `jplan` as an independent, self-contained plugin for the planning pipeline, decoupled from the general-purpose `jinglemansweep` plugin.
- Rename all planning skills from `jms-plan-*` to `jp-plan-*` (with `jms-plan-phase-new` becoming `jp-plan-new`).
- Rename the `jms-planner` agent to `jp-planner`.
- Move and rename the `jms-developer` agent to `jp-developer` within the `jplan` plugin.
- Ensure all quality gate checks pass before the execution pipeline offers to create a PR.
- Enable auto-merge (squash strategy) when the execution pipeline creates a PR.

## Functional Requirements

### REQ-001: Create the jplan plugin directory structure

**Description:** Create a new plugin at `plugins/jplan/` following the existing plugin conventions: `plugin.json`, `install.sh`, `skills/` directory, and `agents/` directory.

**Acceptance Criteria:**

- [ ] `plugins/jplan/plugin.json` exists and contains valid JSON with name `"jplan"`, a version, description, skills list, agents list, and empty commands array.
- [ ] `plugins/jplan/install.sh` exists, is executable, and copies skills and agents to `${CLAUDE_DIR:-$HOME/.claude}/`.
- [ ] `plugins/jplan/skills/` directory exists.
- [ ] `plugins/jplan/agents/` directory exists.

### REQ-002: Move planning skills to jplan with jp- prefix

**Description:** Move all `jms-plan-*` skill directories from `plugins/jinglemansweep/skills/` to `plugins/jplan/skills/` and rename them from `jms-plan-*` to `jp-plan-*`. The special case is `jms-plan-phase-new` which becomes `jp-plan-new` (dropping "phase" from the name).

**Mapping:**

| Old name | New name |
|---|---|
| `jms-plan-init` | `jp-plan-init` |
| `jms-plan-phase-new` | `jp-plan-new` |
| `jms-plan-prd` | `jp-plan-prd` |
| `jms-plan-prd-review` | `jp-plan-prd-review` |
| `jms-plan-task-breakdown` | `jp-plan-task-breakdown` |
| `jms-plan-task-review` | `jp-plan-task-review` |
| `jms-plan-execute` | `jp-plan-execute` |
| `jms-plan-task-validate` | `jp-plan-task-validate` |
| `jms-plan-code-review` | `jp-plan-code-review` |
| `jms-plan-fix` | `jp-plan-fix` |
| `jms-plan-summary` | `jp-plan-summary` |
| `jms-plan-workflow` | `jp-plan-workflow` |

**Acceptance Criteria:**

- [ ] Each old skill directory no longer exists under `plugins/jinglemansweep/skills/`.
- [ ] Each new skill directory exists under `plugins/jplan/skills/` with its `SKILL.md` file.
- [ ] `jms-plan-phase-new` is renamed to `jp-plan-new` (not `jp-plan-phase-new`).
- [ ] All other skills follow the `jms-plan-X` → `jp-plan-X` pattern exactly.

### REQ-003: Update internal cross-references in skill SKILL.md files

**Description:** Every moved SKILL.md file contains references to other planning skills (e.g. `/jms-plan-prd`, `/jms-plan-task-breakdown`, `jms-plan-execute`, etc.) and to the `jms-planner` and `jms-developer` agents. Update all `jms-plan-*` skill references to their new `jp-plan-*` names, `jms-planner` to `jp-planner`, and `jms-developer` to `jp-developer`.

**Acceptance Criteria:**

- [ ] No SKILL.md file under `plugins/jplan/skills/` contains the string `jms-plan-` (except where referring to old names in cleanup/migration comments).
- [ ] All `/jms-plan-*` skill invocations are updated to `/jp-plan-*` equivalents.
- [ ] References to `jms-plan-phase-new` are updated to `jp-plan-new`.
- [ ] References to `jms-planner` are updated to `jp-planner`.
- [ ] References to `jms-developer` are updated to `jp-developer`.
- [ ] Each SKILL.md `name:` frontmatter field matches the new skill name.

### REQ-004: Move and rename the planner agent

**Description:** Move `plugins/jinglemansweep/agents/jms-planner.md` to `plugins/jplan/agents/jp-planner.md` and update all internal references within the file.

**Acceptance Criteria:**

- [ ] `plugins/jplan/agents/jp-planner.md` exists.
- [ ] `plugins/jinglemansweep/agents/jms-planner.md` no longer exists.
- [ ] The agent file's internal references to `jms-plan-*` skills use the new `jp-plan-*` names.
- [ ] The agent's name/identity fields reference `jp-planner`.

### REQ-005: Update jinglemansweep plugin after extraction

**Description:** Remove all planning skills, the planner agent, and the developer agent from the `jinglemansweep` plugin metadata and install script.

**Acceptance Criteria:**

- [ ] `plugins/jinglemansweep/plugin.json` no longer lists any `jms-plan-*` skills.
- [ ] `plugins/jinglemansweep/plugin.json` no longer lists the `jms-planner` or `jms-developer` agents.
- [ ] `plugins/jinglemansweep/plugin.json` retains all non-plan skills (`jms-git`, `jms-git-push`, `jms-role-*`).
- [ ] `plugins/jinglemansweep/install.sh` no longer copies `jms-plan-*` skills, `jms-planner.md`, or `jms-developer.md` agents.

### REQ-006: Create jplan install.sh with old-name cleanup

**Description:** The `jplan` plugin's `install.sh` must copy its skills and agents to `~/.claude/`.

**Acceptance Criteria:**

- [ ] `plugins/jplan/install.sh` copies `skills/*` and `agents/*` to `${CLAUDE_DIR:-$HOME/.claude}/`.

### REQ-007: Update marketplace.json

**Description:** Add the `jplan` plugin to the marketplace registry.

**Acceptance Criteria:**

- [ ] `marketplace.json` contains an entry for `jplan` with name, description, and path `"plugins/jplan"`.
- [ ] The existing `jinglemansweep` and `agentmap` entries are unchanged.

### REQ-008: Enforce quality gates before PR offer in execution pipeline

**Description:** In the execution pipeline (currently `jms-plan-execute`, becoming `jp-plan-execute`), after the review-fix loop completes and before offering to create a PR (Step 10), run a final quality gate check. If any checks fail, report the failures and do not offer the PR creation option until the user acknowledges or resolves them.

**Acceptance Criteria:**

- [ ] After the review-fix loop exits, a final validation pass runs `/jp-plan-task-validate` against all files created or modified during the phase.
- [ ] If validation returns PASS, the PR creation option is offered normally.
- [ ] If validation returns FAIL, the failures are reported to the user and the PR creation option is withheld. The user is instead offered options to: (a) attempt to fix the issues, (b) proceed with PR creation despite failures, or (c) stop.
- [ ] The quality gate result is recorded in `state.yaml` (e.g. `quality_gate: pass` or `quality_gate: fail`).

### REQ-009: Enable auto-merge on PR creation in execution pipeline

**Description:** When the execution pipeline creates a PR (user chooses to push and create PR in Step 10), enable auto-merge with squash strategy after creating the PR. This mirrors the behavior already implemented in `jms-git-push` Step 6.

**Acceptance Criteria:**

- [ ] After PR creation, `gh pr merge --auto --squash --delete-branch <pr-url>` is executed.
- [ ] If auto-merge succeeds, the status is reported to the user.
- [ ] If auto-merge fails, it is treated as non-fatal: the user is informed that auto-merge could not be enabled (likely not enabled in repo settings) and the PR was still created successfully.
- [ ] The auto-merge status is included in the final summary output.

### REQ-010: Update .agentmap.yaml

**Description:** Update the project's `.agentmap.yaml` to reflect the new plugin structure: add the `jplan` plugin tree and update the `jinglemansweep` plugin tree to remove extracted skills/agents. Update conventions to include the `jp-` prefix.

**Acceptance Criteria:**

- [ ] `.agentmap.yaml` `tree` section contains a `plugins/jplan/` entry with all `jp-plan-*` skills, `jp-planner` agent, and `jp-developer` agent listed.
- [ ] `.agentmap.yaml` `tree` section for `plugins/jinglemansweep/` no longer lists `jms-plan-*` skills, `jms-planner`, or `jms-developer`.
- [ ] Conventions mention the `jp-` prefix for the jplan plugin.

### REQ-011: Update README.md

**Description:** Update the project README to document the new `jplan` plugin, its skills, and the updated `jinglemansweep` plugin contents.

**Acceptance Criteria:**

- [ ] README.md documents the `jplan` plugin and its skill/agent inventory.
- [ ] README.md reflects the reduced `jinglemansweep` plugin contents (no planning skills/agent).
- [ ] The directory tree in the README matches the actual file structure after the change.

### REQ-012: Update jp-developer agent cross-references

**Description:** The `jp-developer` agent (moved to `jplan` in REQ-013) contains references to `jms-plan-*` skills and the `jms-planner` agent. Update all such references to the new `jp-plan-*` / `jp-planner` names.

**Acceptance Criteria:**

- [ ] `plugins/jplan/agents/jp-developer.md` does not contain stale `jms-plan-*` or `jms-planner` references.
- [ ] All planning skill references in the developer agent use the new `jp-plan-*` names.
- [ ] The agent's name/identity fields reference `jp-developer`.

## Non-Functional Requirements

### REQ-013: Move jms-developer agent to jplan plugin

**Category:** Maintainability

**Description:** Move the `jms-developer` agent from `plugins/jinglemansweep/agents/` to `plugins/jplan/agents/` and rename it to `jp-developer`. Update all internal references. The `jplan` plugin must be fully self-contained -- installable and usable independently of `jinglemansweep`.

**Acceptance Criteria:**

- [ ] `plugins/jplan/agents/jp-developer.md` exists with all internal `jms-plan-*` references updated to `jp-plan-*`.
- [ ] `plugins/jinglemansweep/agents/jms-developer.md` no longer exists.
- [ ] `plugins/jinglemansweep/plugin.json` no longer lists `jms-developer`.
- [ ] `plugins/jplan/plugin.json` lists `jp-developer` in its agents array.
- [ ] No `jplan` skill SKILL.md file references `jms-git`, `jms-git-push`, or any `jms-role-*` skill as a hard dependency.

## Technical Constraints and Assumptions

### Constraints

- Must follow the existing plugin directory structure: `plugin.json`, `install.sh`, `skills/`, `agents/`.
- Each skill is a single `SKILL.md` file in its own directory.
- Each agent is a single Markdown file in the `agents/` directory.
- The `install.sh` scripts use `${CLAUDE_DIR:-$HOME/.claude}` as the install destination.
- No external dependencies may be introduced.
- The GPL-3.0 license applies to all new files.

### Assumptions

- Users install plugins by running `install.sh` manually; there is no automated plugin manager.
- Both `jplan` and `jinglemansweep` plugins will typically be installed together, but `jplan` should work independently.
- The `jp-developer` agent is bundled in the `jplan` plugin alongside the planning skills.
- The `.plans/` directory structure and its files (prompt.md, prd.md, tasks.yaml, state.yaml) are unchanged by this work -- only the skills that operate on them are renamed.

## Scope

### In Scope

- Creating the `jplan` plugin with directory structure, metadata, and install script.
- Moving and renaming all 12 `jms-plan-*` skills to `jp-plan-*` (with `phase-new` → `plan-new`).
- Moving and renaming the `jms-planner` agent to `jp-planner`.
- Moving and renaming the `jms-developer` agent to `jp-developer`.
- Updating all cross-references in skill and agent Markdown files.
- Updating `jinglemansweep` plugin metadata and install script.
- Adding quality gate enforcement to the execute skill before PR creation.
- Adding auto-merge to the execute skill's PR creation flow.
- Updating `marketplace.json`, `.agentmap.yaml`, and `README.md`.

### Out of Scope

- Renaming `jms-git`, `jms-git-push`, or any `jms-role-*` skills.
- Changing the `.plans/` directory structure or file formats.
- Modifying the `agentmap` plugin.
- Adding new planning skills or capabilities beyond the quality gate and auto-merge enhancements.
- Automated migration tooling for existing users (cleanup via install.sh is sufficient).

## Suggested Tech Stack

| Layer | Technology | Rationale |
|---|---|-----------|
| Plugin format | Markdown + JSON + Bash | Specified by project conventions |
| Version control | Git + GitHub CLI (`gh`) | Existing project infrastructure |
| Automation | Bash (`install.sh`) | Specified by project conventions |
