# Task List

> Source: `.plans/20260226/02-claude-md-file/plan.md`

## Research Existing Patterns

- [x] **Read existing project files to extract conventions** — Read `README.md`, `marketplace.json`, `plugins/plan-quick/plugin.json`, one representative `SKILL.md` (e.g. `plugins/plan-quick/skills/pq-init/SKILL.md`), one agent file (e.g. `plugins/plan-quick/agents/pq-planner.md`), and `plugins/plan-quick/install.sh`. Note the patterns: directory structure, naming conventions (`pq-` prefix), file formats (Markdown for skills/agents, JSON for metadata), and any implicit rules. This research informs all subsequent tasks.

## Create CLAUDE.md

- [x] **Create `CLAUDE.md` at the repository root** — Create the file `CLAUDE.md` in the project root with three clearly separated sections as described below. The file should be concise, directive in tone, and focused on actionable instructions rather than descriptive prose.
  - [x] **Write the Project Overview section** — Add a `# Project` heading followed by a brief description: this is a Claude Code plugin marketplace containing skills and agents, currently hosting the `plan-quick` plugin. Include a top-level directory overview listing only `marketplace.json`, `plugins/`, `LICENSE`, and `README.md` with one-line descriptions. Add a line directing the reader to `README.md` for the full directory tree and detailed documentation. Do not duplicate the README content.
  - [x] **Write the Coding Conventions section** — Add a `# Conventions` heading followed by clear directives covering: (1) Plugins live under `plugins/<plugin-name>/` and contain a `plugin.json`, `install.sh`, `skills/`, and `agents/` directory. (2) Each skill is a directory containing a single `SKILL.md` file. (3) Each agent is a single Markdown file in the `agents/` directory. (4) Plugin-scoped resources use a short prefix (e.g. `pq-` for plan-quick) for skill and agent names. (5) Metadata files (`marketplace.json`, `plugin.json`) are JSON. (6) All documentation and skill/agent definitions use Markdown. Scope these conventions to the existing plan-quick plugin patterns only.
  - [x] **Write the Rules section** — Add a `# Rules` heading followed by explicit constraints: (1) Respect the GPL-3.0 license; do not modify `LICENSE`. (2) Follow the existing plugin directory structure when adding or modifying plugins. (3) Do not add external dependencies without discussing with the user first. (4) Keep skills self-contained — one `SKILL.md` per skill directory, no auxiliary files unless necessary. (5) Maintain backward compatibility with the `install.sh` script. (6) Keep instructions general rather than listing specific file inventories to avoid staleness.

## Verify

- [ ] **Verify `CLAUDE.md` is well-formed and accurate** — Read the completed `CLAUDE.md` and verify: (1) it has three clearly separated sections (Project, Conventions, Rules), (2) the project overview matches the current top-level directory structure, (3) conventions are stated as directives, (4) rules include all six constraints listed above, (5) no content is duplicated from `README.md`, and (6) the file contains no speculative conventions for future plugins.
