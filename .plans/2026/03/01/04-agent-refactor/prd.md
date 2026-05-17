# Product Requirements Document

> Source: `.plans/2026/03/01/03-agent-refactor/prompt.md`

## Project Overview

Refactor the jinglemansweep plugin's skill and agent architecture to improve naming consistency, add missing capabilities, and consolidate role-based agents into a single Developer agent backed by domain-specific skills. This includes renaming all planning-pipeline skills under a `jms-plan-` prefix, fixing a `.plans` directory detection bug, adding a Git/GitHub skill, creating a unified workflow skill, running skills through a quality pass, and restructuring role agents as reusable skills invoked by a single Developer agent.

## Goals

- Eliminate the recurring false-negative where agents report the `.plans` directory does not exist when it does
- Establish a consistent `jms-plan-*` naming convention for all planning-pipeline skills so their purpose is immediately clear
- Provide a Git/GitHub skill that covers PR management, issue tracking, and CI workflow operations without users needing to remember raw `gh` commands
- Offer a single-command workflow skill that orchestrates the full plan-to-summary pipeline
- Improve skill quality by running all skills through Anthropic's Skill Creator skill
- Reduce agent proliferation by consolidating language/domain-specific role agents into a single Developer agent that delegates to domain skills

## Functional Requirements

### REQ-001: Fix `.plans` Directory Detection

**Description:** Multiple skills (e.g. `jms-plan`, `jms-execute`, `jms-phase-new`) scan for `.plans/` using relative paths, which fails when the agent's working directory differs from the repository root. All skills that reference `.plans/` must resolve the path relative to the git repository root (`git rev-parse --show-toplevel`) rather than the current working directory.

**Acceptance Criteria:**

- [ ] Every skill that scans or references `.plans/` resolves the path using the repository root, not `cwd`
- [ ] Running any `.plans`-dependent skill from a subdirectory of the repository correctly finds and uses the `.plans/` directory at the repository root
- [ ] If `.plans/` genuinely does not exist at the repository root, the skill reports the correct error and suggests running the init skill

### REQ-002: Rename Planning-Pipeline Skills to `jms-plan-*` Prefix

**Description:** Rename all skills that form the planning and execution pipeline to use a `jms-plan-` prefix. The current `jms-plan` skill (which generates the PRD) becomes `jms-plan-prd` to avoid collision with the prefix itself.

**Rename mapping:**

| Current Name | New Name |
|---|---|
| `jms-init` | `jms-plan-init` |
| `jms-phase-new` | `jms-plan-phase-new` |
| `jms-plan` | `jms-plan-prd` |
| `jms-prd-review` | `jms-plan-prd-review` |
| `jms-task-breakdown` | `jms-plan-task-breakdown` |
| `jms-task-review` | `jms-plan-task-review` |
| `jms-execute` | `jms-plan-execute` |
| `jms-validate` | `jms-plan-validate` |
| `jms-code-review` | `jms-plan-code-review` |
| `jms-fix` | `jms-plan-fix` |
| `jms-summary` | `jms-plan-summary` |

`jms-git-push` is NOT part of the planning pipeline and retains its current name.

**Acceptance Criteria:**

- [ ] Each skill directory under `plugins/jinglemansweep/skills/` is renamed according to the mapping above
- [ ] Each `SKILL.md` file's frontmatter `name` field and heading match the new name
- [ ] All cross-references between skills (e.g. `/jms-plan` references inside `jms-execute`, `jms-planner` agent pipeline overview) are updated to use the new names
- [ ] `plugin.json` lists the new skill names
- [ ] `install.sh` installs skills under their new names
- [ ] The `jms-planner` agent's pipeline overview and workflow steps reference the new skill names

### REQ-003: Add Git/GitHub Skill

**Description:** Create a new `jms-git` skill that provides a structured interface for common GitHub operations using the `gh` CLI. The skill covers pull request management, issue management, and CI/workflow operations. It should NOT cover local git operations (commit, push, pull, branch) which belong to standard git usage.

**Acceptance Criteria:**

- [ ] A new skill directory `plugins/jinglemansweep/skills/jms-git/` exists with a `SKILL.md` file
- [ ] The skill documents when to use it (GitHub remote operations) and when NOT to use it (local git operations)
- [ ] The skill covers: listing/viewing/creating/merging PRs, listing/creating/closing issues, viewing CI/workflow run status and logs, and querying the GitHub API
- [ ] The skill is registered in `plugin.json`
- [ ] The skill references `gh` CLI commands with examples for each operation category
- [ ] The skill follows the existing SKILL.md structure: frontmatter with `name`, `description`, `allowed-tools`, followed by markdown instructions

### REQ-004: Add Unified Workflow Skill

**Description:** Create a new `jms-plan-workflow` skill that wraps the full planning-to-summary pipeline in a single invocation. The workflow skill orchestrates the sequence: init -> phase-new -> plan-prd -> prd-review -> task-breakdown -> task-review -> execute -> summary. It provides a guided, end-to-end experience for users who want to go from a prompt to a completed implementation without manually invoking each step.

**Acceptance Criteria:**

- [ ] A new skill directory `plugins/jinglemansweep/skills/jms-plan-workflow/` exists with a `SKILL.md` file
- [ ] The skill accepts a phase description (or existing phase path) as input
- [ ] The skill orchestrates all pipeline stages in order, delegating to the individual `jms-plan-*` skills
- [ ] The skill handles REVISE/ESCALATE verdicts from review stages (re-running or prompting the user as appropriate)
- [ ] The skill provides progress updates between stages
- [ ] The skill is registered in `plugin.json`
- [ ] The skill can be resumed if interrupted (leveraging `state.yaml` for execution state)

### REQ-005: Consolidate Role Agents into Developer Agent with Domain Skills

**Description:** Replace the current set of language/domain-specific role agents (`jms-role-python`, `jms-role-nodejs`, `jms-role-frontend`, `jms-role-devops`, `jms-role-docs`, `jms-role-skills`) with:

1. A set of **domain skills** -- one per current role agent -- that encapsulate the domain knowledge, conventions, and quality gates currently in the role agent Markdown files.
2. A single **Developer agent** (`jms-developer`) that receives tasks, determines which domain skill(s) are relevant, loads those skills, and executes the task within its own context window.

The `jms-role-general` agent is absorbed into the Developer agent's base behaviour (it becomes the fallback when no domain skill matches).

**Acceptance Criteria:**

- [ ] New domain skill directories exist under `plugins/jinglemansweep/skills/` for each converted role: `jms-skill-python`, `jms-skill-nodejs`, `jms-skill-frontend`, `jms-skill-devops`, `jms-skill-docs`, `jms-skill-skills`
- [ ] Each domain skill's `SKILL.md` contains the domain knowledge, conventions, recommended packages, quality gates, and workflow from the corresponding role agent
- [ ] A new `jms-developer` agent Markdown file exists in `plugins/jinglemansweep/agents/`
- [ ] The Developer agent's definition includes logic to select the appropriate domain skill based on task signals (file extensions, frameworks, keywords) -- mirroring the signal-matching currently in `jms-plan-execute`
- [ ] The Developer agent loads the selected domain skill's conventions and follows them during implementation
- [ ] The previous role agent files (`jms-role-python.md`, `jms-role-nodejs.md`, `jms-role-frontend.md`, `jms-role-devops.md`, `jms-role-docs.md`, `jms-role-skills.md`, `jms-role-general.md`) are removed
- [ ] The `jms-plan-execute` skill's role agent configuration and role mapping table are updated to use `jms-developer` as the sole agent, with domain skills as the specialisation mechanism
- [ ] `plugin.json` is updated: old role agents removed, `jms-developer` added, new domain skills added
- [ ] `install.sh` installs the new agent and skills and no longer installs removed agents

### REQ-006: Quality Pass -- Run Skills Through Anthropic Skill Creator

**Description:** Review every skill `SKILL.md` file against Anthropic's Skill Creator best practices and guidelines. Apply improvements to structure, clarity, testability of instructions, and consistency across all skills. This is a quality review using the Skill Creator skill -- each skill is evaluated and improved for clarity, completeness, and adherence to best practices.

**Acceptance Criteria:**

- [ ] Every `SKILL.md` file in the plugin has been reviewed for clarity, completeness, and adherence to Anthropic's skill authoring guidelines
- [ ] Skills follow a consistent structure: frontmatter, description, usage, instructions (numbered steps), guidelines, and constraints
- [ ] Ambiguous or vague instructions in skills are rewritten to be specific and actionable
- [ ] Cross-skill consistency is verified (e.g. all skills that accept a phase-path argument handle it the same way)
- [ ] Every `SKILL.md` has valid frontmatter with `name`, `description`, and `allowed-tools` fields

### REQ-007: Update `jms-planner` Agent for New Architecture

**Description:** Update the `jms-planner` agent to reference the renamed `jms-plan-*` skills and to mention the new `jms-plan-workflow` skill as an alternative for users who want the fully automated pipeline.

**Acceptance Criteria:**

- [ ] The `jms-planner` pipeline overview uses the new `jms-plan-*` skill names
- [ ] All workflow step references use the new skill names
- [ ] The agent mentions `/jms-plan-workflow` as an alternative to the step-by-step pipeline
- [ ] The hand-off message at Step 7 references `/jms-plan-execute` (new name)

## Non-Functional Requirements

### REQ-008: Backward Compatibility of `install.sh`

**Category:** Maintainability

**Description:** The `install.sh` script must correctly install all renamed skills and the new agent, and must clean up old skill/agent names from `~/.claude/` to prevent stale artefacts from previous installations.

**Acceptance Criteria:**

- [ ] `install.sh` installs skills under their new names to `~/.claude/skills/`
- [ ] `install.sh` installs the new `jms-developer` agent to `~/.claude/agents/`
- [ ] `install.sh` removes old skill directories (e.g. `~/.claude/skills/jms-plan/`, `~/.claude/skills/jms-execute/`) that no longer exist under the new naming
- [ ] `install.sh` removes old agent files (e.g. `~/.claude/agents/jms-role-python.md`) that have been replaced

### REQ-009: Documentation Currency

**Category:** Maintainability

**Description:** All project documentation must reflect the new naming, architecture, and capabilities.

**Acceptance Criteria:**

- [ ] `README.md` documents the new skill names, the Developer agent, the Git skill, and the workflow skill
- [ ] `CLAUDE.md` is updated if any conventions or rules change as a result of this refactor
- [ ] `.agentmap.yaml` is regenerated to reflect the new directory structure and skill/agent inventory

### REQ-010: Naming Consistency

**Category:** Maintainability

**Description:** All skill and agent names must follow the established prefix conventions and be internally consistent across all configuration and documentation files.

**Acceptance Criteria:**

- [ ] Every skill's directory name matches its `SKILL.md` frontmatter `name` field
- [ ] Every agent's filename (minus `.md`) matches its frontmatter `name` field
- [ ] `plugin.json` skill and agent lists match the actual directory/file inventory
- [ ] No references to old skill or agent names remain in any project file

## Technical Constraints and Assumptions

### Constraints

- All changes must stay within the existing plugin directory structure (`plugins/jinglemansweep/`)
- Skills remain self-contained: one `SKILL.md` per skill directory, no auxiliary files unless necessary
- The `jms-` prefix is reserved for the jinglemansweep plugin
- `install.sh` must remain a standalone bash script with no external dependencies beyond standard Unix tools and `git`
- The GPL-3.0 license must not be modified

### Assumptions

- The `gh` CLI is available on systems where the Git skill will be used
- Anthropic's Skill Creator guidelines are accessible to the agent performing the quality pass (either via built-in knowledge or the `claude-developer-platform` skill)
- The Developer agent will be spawned via the Claude Code `Task` tool, which provides each agent its own context window -- confirming the user's assumption about agent context isolation
- Domain skills loaded by the Developer agent are additive instructions, not separate agent processes -- the Developer agent reads the skill content and follows its conventions within its own execution

## Scope

### In Scope

- Renaming all planning-pipeline skills to `jms-plan-*` (including `jms-init` -> `jms-plan-init`)
- Fixing `.plans` directory detection across all affected skills
- Creating the `jms-git` skill
- Creating the `jms-plan-workflow` skill
- Converting role agents to domain skills and creating the `jms-developer` agent
- Quality pass on all skill SKILL.md files
- Updating `jms-planner` agent references
- Updating `plugin.json`, `install.sh`, `README.md`, `CLAUDE.md`, `.agentmap.yaml`
- Cleanup of old skill directories and agent files
- Cleanup of stale installed artefacts via `install.sh`

### Out of Scope

- Changes to the `agentmap` plugin (separate plugin, separate concerns)
- Adding new domain skills beyond those derived from existing role agents
- Modifying the planning pipeline logic (the skills' internal behaviour stays the same; only names and cross-references change)
- Automated testing infrastructure for skills (no test framework exists for skill Markdown files)
- Changes to `marketplace.json` beyond what is needed for the plugin name/version
- Migrating existing `.plans/` phase artefacts to use new skill names in their logs

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Skill definitions | Markdown (SKILL.md) | Specified by project conventions |
| Agent definitions | Markdown (.md) | Specified by project conventions |
| Installation | Bash (install.sh) | Specified by project conventions |
| Metadata | JSON (plugin.json) | Specified by project conventions |
| Git/GitHub operations | `gh` CLI | Standard GitHub CLI, referenced by the openclaw skill |
| Codebase map | YAML (.agentmap.yaml) | Specified by agentmap plugin conventions |
