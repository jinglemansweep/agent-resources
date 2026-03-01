# Agentic Dev Resources

![pre-commit](https://github.com/jinglemansweep/agent-resources/actions/workflows/pre-commit.yml/badge.svg) ![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)

A personal Claude Code agent and skill toolkit. Currently hosts the `jinglemansweep`, `jplan`, and `agentmap` plugins.

Licensed under GPL-3.0.

## Directory Structure

```text
.github/
  workflows/
    pre-commit.yml          # CI workflow — runs pre-commit on push/PR to main
.markdownlint.yaml          # Markdownlint rule overrides
.pre-commit-config.yaml     # Pre-commit hook configuration
CLAUDE.md                   # Claude Code agent instructions and project conventions
marketplace.json            # Marketplace metadata listing available plugins
plugins/                    # Directory containing all plugins
  jinglemansweep/           # The jinglemansweep plugin
    .claude/
      settings.local.json   # Plugin-specific Claude permissions
    plugin.json             # Plugin metadata (name, version, skills)
    install.sh              # Installation script
    skills/                 # Skill definitions (each contains a SKILL.md)
      jms-git/
  jplan/                    # The jplan plugin (planning pipeline)
    plugin.json             # Plugin metadata (name, version, skills, agents)
    install.sh              # Installation script
    skills/                 # Skill definitions (each contains a SKILL.md)
      jp-setup/
      jp-plan/
      jp-prd/
      jp-prd-review/
      jp-task-list/
      jp-task-review/
      jp-execute/
      jp-task-validate/
      jp-codereview/
      jp-codereview-fix/
      jp-summary/
      jp-quick/
      jp-persona-python/
      jp-persona-nodejs/
      jp-persona-frontend/
      jp-persona-devops/
      jp-persona-docs/
      jp-persona-agent-skills/
    agents/                 # Agent definitions
      jp-worker-dev.md
  agentmap/                 # The agentmap plugin
    plugin.json             # Plugin metadata (name, version, skills)
    install.sh              # Installation script
    README.md               # Plugin documentation
    example.agentmap.yaml   # Reference agentmap demonstrating all schema sections
    skills/                 # Skill definitions (each contains a SKILL.md)
      agentmap-init/
      agentmap-read/
      agentmap-generate/
LICENSE                     # GPL-3.0 license
README.md                   # This file
```

## Plugins

### jinglemansweep

Personal Skills.

**Version:** 0.4.0

**Skills:**

- `jms-git` — Structured interface for GitHub operations using the `gh` CLI (pull requests, issues, CI/workflow runs, and API queries)

### jplan

Planning Pipeline Skills and Agents.

**Version:** 0.1.0

**Pipeline:** Plan -> PRD -> PRD Review -> Task List -> Task Review -> Execute (with Validate, Code Review, Fix, Summary sub-stages)

**Phase directory format:** `.plans/YYYY/MM/DD/NN-slug`

**Artifacts:** `prompt.md` (user input), `prd.md` (product requirements document), `tasks.yaml` (structured task list), `state.yaml` (pipeline state)

**Skills:**

- `jp-setup` — Initialize the `.plans` directory structure for a project
- `jp-plan` — Create a new datestamped planning phase directory (`YYYY/MM/DD/NN-slug`) with branch setup
- `jp-prd` — Generate a structured product requirements document (`prd.md`) from a prompt file
- `jp-prd-review` — Critically evaluate the PRD for coverage, contradictions, ambiguity, and feasibility
- `jp-task-list` — Convert an approved PRD into a structured YAML task list (`tasks.yaml`)
- `jp-task-review` — Validate the task list structure, dependency ordering, and PRD coverage
- `jp-execute` — Full pipeline orchestrator: processes tasks sequentially with agent delegation, validation, code review, fix loops, and summary generation
- `jp-task-validate` — Post-task automated validation: syntax, linting, type checking, and tests
- `jp-codereview` — Holistic code review with severity-rated issue tracking in YAML format
- `jp-codereview-fix` — Apply corrections based on code review feedback (CRITICAL and MAJOR issues)
- `jp-summary` — Generate a final workflow summary report covering tasks, reviews, and decisions
- `jp-quick` — End-to-end planning pipeline orchestration: runs the full pipeline from prompt to summary in a single invocation, with review verdict handling and resumption support

Domain skills (loaded by the Developer agent based on task signals):

- `jp-persona-python` — Python backend conventions and quality gates
- `jp-persona-nodejs` — Node.js/TypeScript conventions and quality gates
- `jp-persona-frontend` — Frontend/UI conventions and quality gates
- `jp-persona-devops` — Infrastructure and CI/CD conventions and quality gates
- `jp-persona-docs` — Documentation conventions and quality gates
- `jp-persona-agent-skills` — Skill authoring conventions and quality gates

**Agents:**

- `jp-worker-dev` — General-purpose developer agent that delegates to domain-specific skills. Examines task signals (file extensions, tools, frameworks) to automatically load the appropriate domain skill(s) and follows their conventions during implementation. Falls back to general software engineering practices when no domain matches.

### agentmap

AI-powered codebase orientation maps.

**Version:** 0.1.0

**Skills:**

- `agentmap-init` — Check for `.agentmap.yaml` and guide initial setup if missing
- `agentmap-read` — Teaches agents how to consume `.agentmap.yaml` codebase orientation maps
- `agentmap-generate` — Generate or update an `.agentmap.yaml` codebase orientation map

## Installation

1. Clone the repository:

   ```bash
   git clone <repo-url>
   ```

2. Navigate to the plugin directory:

   ```bash
   cd plugins/jinglemansweep
   ```

3. Run the install script:

   ```bash
   bash install.sh
   ```

This copies skills into `~/.claude/skills/` and agents into `~/.claude/agents/`.

To install to a custom location, set the `CLAUDE_DIR` environment variable:

```bash
CLAUDE_DIR=/path/to/custom/.claude bash install.sh
```

## Configuration

Plugins may include their own `.claude/settings.local.json` with plugin-specific settings. The `install.sh` script copies skill and agent files but does not copy settings. Users may need to merge plugin settings into their own `.claude/settings.local.json` depending on their environment.

## Pre-Commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) to run automated checks before each commit. The configuration is defined in `.pre-commit-config.yaml`.

### What the Hooks Enforce

| Hook | Purpose |
|---|---|
| `check-json` | Validates JSON syntax |
| `check-yaml` | Validates YAML syntax |
| `trailing-whitespace` | Removes trailing whitespace |
| `end-of-file-fixer` | Ensures files end with a newline |
| `check-merge-conflict` | Detects unresolved merge conflict markers |
| `check-added-large-files` | Prevents committing large files |
| `detect-private-key` | Prevents committing private keys |
| `markdownlint` | Lints Markdown files (excludes `.plans/`) |
| `shellcheck` | Lints shell scripts |

### Installation

```bash
pip install pre-commit
pre-commit install
```

Once installed, hooks run automatically on every `git commit`.

### Manual Usage

To run all hooks against every file in the repository:

```bash
pre-commit run --all-files
```

### Markdownlint Configuration

The `.markdownlint.yaml` file customizes the Markdown linting rules for this project:

- **MD013** (line length) — disabled because existing files have long prose lines
- **MD024** (no duplicate headings) — disabled because skill files reuse heading names like "Step 1", "Step 2"
- **MD033** (no inline HTML) — disabled because template files use HTML comments
- **MD041** (first line heading) — disabled because SKILL.md files start with YAML front matter

The `.plans/` directory is excluded from Markdown linting via both the markdownlint config (`ignores` key) and the pre-commit hook config (`exclude` pattern).

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
