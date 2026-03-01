# Product Requirements Document

> Source: `.plans/2026/03/01/08-fixes-renames/prompt.md`

## Project Overview

This phase restructures the `jplan` and `jinglemansweep` plugins by consolidating domain-role skills into `jplan` under a new `jp-persona-*` naming convention, renaming the `jp-developer` agent to `jp-worker-dev`, shortening all `jp-plan-*` skill names, injecting a documentation quality gate into the execution loop, and generating an example `settings.local.json` file with full permission allowlists. The goal is a cleaner, more consistent naming scheme and a more complete automation pipeline.

## Goals

- Consolidate all domain-role skills into the `jplan` plugin under the `jp-persona-*` namespace, eliminating their presence in the `jinglemansweep` plugin.
- Shorten `jp-plan-*` skill names to concise `jp-*` equivalents for better ergonomics.
- Rename the `jp-developer` agent to `jp-worker-dev` to better reflect its role.
- Ensure documentation is automatically reviewed before push/PR options in the execution pipeline.
- Provide a ready-to-use example `settings.local.json` covering all skills, agents, and bash commands in the repo.
- Update all cross-references, documentation, manifests, and configuration files to reflect every rename.

## Functional Requirements

### REQ-001: Move and Rename Domain-Role Skills to jplan Plugin

**Description:** Move the six `jms-role-*` skill directories from `plugins/jinglemansweep/skills/` into `plugins/jplan/skills/`, renaming them from `jms-role-*` to `jp-persona-*`:

| Current (jinglemansweep) | New (jplan) |
|---|---|
| `jms-role-python` | `jp-persona-python` |
| `jms-role-nodejs` | `jp-persona-nodejs` |
| `jms-role-frontend` | `jp-persona-frontend` |
| `jms-role-devops` | `jp-persona-devops` |
| `jms-role-docs` | `jp-persona-docs` |
| `jms-role-agent-skills` | `jp-persona-agent-skills` |

**Acceptance Criteria:**

- [ ] Each `jms-role-*` directory is removed from `plugins/jinglemansweep/skills/`.
- [ ] Each corresponding `jp-persona-*` directory exists under `plugins/jplan/skills/` with the same `SKILL.md` content (updated for the new name where the old name appears in the SKILL.md itself).
- [ ] `plugins/jinglemansweep/plugin.json` no longer lists any `jms-role-*` skills.
- [ ] `plugins/jplan/plugin.json` lists all six `jp-persona-*` skills.
- [ ] The `jms-git` skill remains in the `jinglemansweep` plugin, unaffected.

### REQ-002: Rename jp-developer Agent to jp-worker-dev

**Description:** Rename the agent file from `plugins/jplan/agents/jp-developer.md` to `plugins/jplan/agents/jp-worker-dev.md`. Update the agent's internal content to reflect the new name, and update the routing table within the agent to reference `jp-persona-*` skills instead of `jms-role-*` skills.

**Acceptance Criteria:**

- [ ] `plugins/jplan/agents/jp-developer.md` no longer exists.
- [ ] `plugins/jplan/agents/jp-worker-dev.md` exists with updated content.
- [ ] The agent's domain-skill routing table references `jp-persona-*` names instead of `jms-role-*` names.
- [ ] `plugins/jplan/plugin.json` references `jp-worker-dev` instead of `jp-developer` in the agents section.

### REQ-003: Rename jp-plan-* Skills to Shorter Names

**Description:** Rename all twelve `jp-plan-*` skill directories under `plugins/jplan/skills/` according to the following mapping:

| Current | New |
|---|---|
| `jp-plan-code-review` | `jp-codereview` |
| `jp-plan-execute` | `jp-execute` |
| `jp-plan-fix` | `jp-codereview-fix` |
| `jp-plan-init` | `jp-setup` |
| `jp-plan-new` | `jp-plan` |
| `jp-plan-prd` | `jp-prd` |
| `jp-plan-prd-review` | `jp-prd-review` |
| `jp-plan-summary` | `jp-summary` |
| `jp-plan-task-breakdown` | `jp-task-list` |
| `jp-plan-task-review` | `jp-task-review` |
| `jp-plan-task-validate` | `jp-task-validate` |
| `jp-plan-workflow` | `jp-quick` |

**Acceptance Criteria:**

- [ ] Each old `jp-plan-*` skill directory no longer exists under `plugins/jplan/skills/`.
- [ ] Each new `jp-*` skill directory exists with the corresponding `SKILL.md`.
- [ ] `plugins/jplan/plugin.json` lists all twelve skills under their new names.

### REQ-004: Update All Cross-References in SKILL.md Files

**Description:** Every `SKILL.md` that references another skill by its old name (e.g. "run `/jp-plan-prd`" or "invoke `jms-role-python`") must be updated to use the new name. This includes:
- Skill invocation references (e.g. `/jp-plan-prd` becomes `/jp-prd`)
- Mentions of skill names in prose or tables
- References to the agent name (`jp-developer` becomes `jp-worker-dev`)

**Acceptance Criteria:**

- [ ] No `SKILL.md` file in the repository contains any old `jp-plan-*` skill name.
- [ ] No `SKILL.md` file in the repository contains any `jms-role-*` skill name.
- [ ] No `SKILL.md` file in the repository contains the old agent name `jp-developer`.
- [ ] All cross-references use the correct new names per the mapping tables in REQ-001, REQ-002, and REQ-003.

### REQ-005: Add Documentation Gate to Execution Loop

**Description:** In the `jp-execute` skill (formerly `jp-plan-execute`), add a step after all tasks have been completed and the review/fix loop has concluded, but before presenting the push/PR options to the user. This new step invokes the `jp-persona-docs` skill (formerly `jms-role-docs`) to review and update project documentation (README.md, inline docs, etc.) ensuring documentation stays current with the changes made during the phase.

**Acceptance Criteria:**

- [ ] The `jp-execute` SKILL.md contains a documentation step that invokes `jp-persona-docs` after the review/fix cycle completes.
- [ ] The documentation step runs before the user is presented with push/PR/stop options.
- [ ] The step is clearly documented in the SKILL.md with its position in the pipeline.

### REQ-006: Generate Example settings.local.json

**Description:** Create an example `settings.local.json` file at the repository root (e.g. `settings.local.example.json`) that includes `allow` permission entries for all skills, agents, tools, and common bash commands used by the skills and agents in this repository. This serves as a reference users can copy into their `.claude/settings.local.json`.

**Acceptance Criteria:**

- [ ] An example settings file exists at the repository root named `settings.local.example.json`.
- [ ] The file contains `allow` entries for every skill in the repo (using the new names): all `jp-*` skills, all `agentmap-*` skills, and `jms-git`.
- [ ] The file contains `allow` entries for the `jp-worker-dev` agent.
- [ ] The file contains `allow` entries for common bash commands used by the skills (e.g. `git`, `gh`, `npm`, `pip`, `python`, `node`, etc.).
- [ ] The file is valid JSON and follows the Claude Code settings schema.

### REQ-007: Update Plugin Manifests (plugin.json)

**Description:** Update both plugin manifest files to reflect all renames:

- `plugins/jplan/plugin.json`: Update skill list to new `jp-*` names, add `jp-persona-*` skills, update agent reference to `jp-worker-dev`.
- `plugins/jinglemansweep/plugin.json`: Remove the six `jms-role-*` skill entries (only `jms-git` remains).

**Acceptance Criteria:**

- [ ] `plugins/jplan/plugin.json` lists all new `jp-*` skill names and all `jp-persona-*` skill names.
- [ ] `plugins/jplan/plugin.json` references `jp-worker-dev` as the agent.
- [ ] `plugins/jinglemansweep/plugin.json` only lists `jms-git` as a skill and has no agents.
- [ ] Both files are valid JSON.

### REQ-008: Update README.md

**Description:** Update the project `README.md` to reflect all renames: new skill names, new persona names, new agent name, updated directory tree, and updated pipeline flow descriptions.

**Acceptance Criteria:**

- [ ] The README directory tree reflects the new skill and agent directory names.
- [ ] All skill references use the new `jp-*` and `jp-persona-*` names.
- [ ] The agent is referenced as `jp-worker-dev`.
- [ ] The pipeline flow description uses the new skill names.
- [ ] No references to old `jp-plan-*`, `jms-role-*`, or `jp-developer` names remain.

### REQ-009: Update .agentmap.yaml

**Description:** Update `.agentmap.yaml` to reflect all renames: new skill names, new persona names, and new agent name.

**Acceptance Criteria:**

- [ ] All skill entries use the new `jp-*` and `jp-persona-*` names.
- [ ] The agent entry references `jp-worker-dev`.
- [ ] No references to old names remain.
- [ ] The file is valid YAML.

### REQ-010: Update Existing settings.local.json Files

**Description:** Update the existing `.claude/settings.local.json` files in the repository to use the new skill, persona, and agent names. Also remove any stale/obsolete entries (e.g. `jms-plan-code-review`, `jms-plan-summary`).

**Acceptance Criteria:**

- [ ] `.claude/settings.local.json` uses the new `jp-*` skill names, `jp-persona-*` names, and `jp-worker-dev` agent name.
- [ ] All stale `jms-plan-*` references are removed.
- [ ] `plugins/jinglemansweep/.claude/settings.local.json` is updated (no longer references `jms-plan-init`; only references `jms-git` if needed, or is removed if empty).
- [ ] Both files are valid JSON.

### REQ-011: Update install.sh Scripts

**Description:** Update the `install.sh` scripts in both plugins to reflect the new skill directory names and agent name, ensuring symlinks and installation logic reference the correct paths.

**Acceptance Criteria:**

- [ ] `plugins/jplan/install.sh` references all new `jp-*` and `jp-persona-*` skill directory names.
- [ ] `plugins/jplan/install.sh` references the `jp-worker-dev` agent.
- [ ] `plugins/jinglemansweep/install.sh` only references `jms-git` (and no `jms-role-*` skills).
- [ ] Both scripts execute without errors.

## Non-Functional Requirements

### REQ-012: No Broken Cross-References

**Category:** Maintainability

**Description:** After all renames are complete, no file in the repository (excluding `.plans/` historical logs) should contain any reference to the old skill names (`jp-plan-*`, `jms-role-*`) or old agent name (`jp-developer`) in an active/instructional context.

**Acceptance Criteria:**

- [ ] A grep for `jp-plan-code-review`, `jp-plan-execute`, `jp-plan-fix`, `jp-plan-init`, `jp-plan-new`, `jp-plan-prd`, `jp-plan-prd-review`, `jp-plan-summary`, `jp-plan-task-breakdown`, `jp-plan-task-review`, `jp-plan-task-validate`, `jp-plan-workflow` returns no matches outside of `.plans/` directories.
- [ ] A grep for `jms-role-python`, `jms-role-nodejs`, `jms-role-frontend`, `jms-role-devops`, `jms-role-docs`, `jms-role-agent-skills` returns no matches outside of `.plans/` directories.
- [ ] A grep for `jp-developer` (as a skill/agent reference, not a generic word) returns no matches outside of `.plans/` directories.

### REQ-013: Backward-Compatible install.sh

**Category:** Reliability

**Description:** The `install.sh` scripts must continue to work correctly after renames -- creating proper symlinks in the user's `~/.claude/skills/` and `~/.claude/agents/` directories for the new names.

**Acceptance Criteria:**

- [ ] Running `plugins/jplan/install.sh` creates symlinks for all `jp-*` and `jp-persona-*` skills and the `jp-worker-dev` agent.
- [ ] Running `plugins/jinglemansweep/install.sh` creates a symlink only for `jms-git`.
- [ ] No dangling symlinks to old names are created.

## Technical Constraints and Assumptions

### Constraints

- All changes must stay within the existing plugin directory structure convention (`plugins/<name>/skills/<skill-name>/SKILL.md`).
- The `jms-git` skill must remain in the `jinglemansweep` plugin, unaffected.
- The `agentmap` plugin is unaffected by these changes.
- Historical `.plans/` log files should not be modified -- old names in past logs are acceptable.
- The GPL-3.0 license file must not be modified.

### Assumptions

- The `install.sh` scripts use symlinks to install skills/agents into `~/.claude/skills/` and `~/.claude/agents/`.
- Users will re-run `install.sh` after this update to get the new symlinks.
- The `marketplace.json` file at the repo root may also need updating if it references specific skill names (to be verified during implementation).

## Scope

### In Scope

- Moving and renaming `jms-role-*` skills to `jp-persona-*` in the `jplan` plugin.
- Renaming `jp-developer` agent to `jp-worker-dev`.
- Renaming all twelve `jp-plan-*` skills to shorter `jp-*` names.
- Adding a documentation gate step to the execution pipeline.
- Generating an example `settings.local.json` file.
- Updating all manifests, config files, documentation, and cross-references.

### Out of Scope

- Changes to the `agentmap` plugin.
- Changes to the `jms-git` skill content or behavior.
- Changes to SKILL.md logic/behavior (only names and references change, not functionality).
- Modifying historical `.plans/` log files.
- Publishing or versioning updates to `marketplace.json` beyond name corrections.
- Removing old symlinks from user machines (users must re-run `install.sh`).

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| File format | Markdown (SKILL.md, agents) | Specified by project conventions |
| Metadata | JSON (plugin.json, settings.json) | Specified by project conventions |
| State | YAML (state.yaml, .agentmap.yaml) | Specified by project conventions |
| Installation | Bash (install.sh) | Specified by project conventions |
| VCS | Git + GitHub CLI (gh) | Specified by project conventions |
