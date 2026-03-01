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
      jms-git-push/
      jms-role-python/
      jms-role-nodejs/
      jms-role-frontend/
      jms-role-devops/
      jms-role-docs/
      jms-role-agent-skills/
  jplan/                    # The jplan plugin (planning pipeline)
    plugin.json             # Plugin metadata (name, version, skills, agents)
    install.sh              # Installation script
    skills/                 # Skill definitions (each contains a SKILL.md)
      jp-plan-init/
      jp-plan-new/
      jp-plan-prd/
      jp-plan-prd-review/
      jp-plan-task-breakdown/
      jp-plan-task-review/
      jp-plan-execute/
      jp-plan-task-validate/
      jp-plan-code-review/
      jp-plan-fix/
      jp-plan-summary/
      jp-plan-workflow/
    agents/                 # Agent definitions
      jp-planner.md
      jp-developer.md
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

Git skills:

- `jms-git` — Structured interface for GitHub operations using the `gh` CLI (pull requests, issues, CI/workflow runs, and API queries)
- `jms-git-push` — Automate branch creation, PR submission, and auto-merge for accidental default-branch commits

Domain skills (loaded by the Developer agent based on task signals):

- `jms-role-python` — Python backend conventions and quality gates
- `jms-role-nodejs` — Node.js/TypeScript conventions and quality gates
- `jms-role-frontend` — Frontend/UI conventions and quality gates
- `jms-role-devops` — Infrastructure and CI/CD conventions and quality gates
- `jms-role-docs` — Documentation conventions and quality gates
- `jms-role-agent-skills` — Skill authoring conventions and quality gates

### jplan

Planning Pipeline Skills and Agents.

**Version:** 0.1.0

**Pipeline:** New Phase -> PRD -> PRD Review -> Task Breakdown -> Task Review -> Execute (with Validate, Code Review, Fix, Summary sub-stages)

**Phase directory format:** `.plans/YYYY/MM/DD/NN-slug`

**Artifacts:** `prompt.md` (user input), `prd.md` (product requirements document), `tasks.yaml` (structured task list), `state.yaml` (pipeline state)

**Skills:**

- `jp-plan-init` — Initialize the `.plans` directory structure for a project
- `jp-plan-new` — Create a new datestamped planning phase directory (`YYYY/MM/DD/NN-slug`) with branch setup
- `jp-plan-prd` — Generate a structured product requirements document (`prd.md`) from a prompt file
- `jp-plan-prd-review` — Critically evaluate the PRD for coverage, contradictions, ambiguity, and feasibility
- `jp-plan-task-breakdown` — Convert an approved PRD into a structured YAML task list (`tasks.yaml`)
- `jp-plan-task-review` — Validate the task list structure, dependency ordering, and PRD coverage
- `jp-plan-execute` — Full pipeline orchestrator: processes tasks sequentially with agent delegation, validation, code review, fix loops, and summary generation
- `jp-plan-task-validate` — Post-task automated validation: syntax, linting, type checking, and tests
- `jp-plan-code-review` — Holistic code review with severity-rated issue tracking in YAML format
- `jp-plan-fix` — Apply corrections based on code review feedback (CRITICAL and MAJOR issues)
- `jp-plan-summary` — Generate a final workflow summary report covering tasks, reviews, and decisions
- `jp-plan-workflow` — End-to-end planning pipeline orchestration: runs the full pipeline from prompt to summary in a single invocation, with review verdict handling and resumption support

**Agents:**

- `jp-planner` — Guides the planning workflow: init, phase creation, PRD generation, PRD review, task breakdown, and task review. For an automated end-to-end experience, invoke `/jp-plan-workflow` instead of stepping through the pipeline manually.
- `jp-developer` — General-purpose developer agent that delegates to domain-specific skills. Examines task signals (file extensions, tools, frameworks) to automatically load the appropriate domain skill(s) and follows their conventions during implementation. Falls back to general software engineering practices when no domain matches.

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

Plugins may include their own `.claude/settings.local.json` with plugin-specific settings. The `jinglemansweep` plugin includes a settings file at `plugins/jinglemansweep/.claude/settings.local.json` which configures automatic permission for the `jms-plan-init` skill:

```json
{
  "permissions": {
    "allow": [
      "Skill(jms-plan-init)"
    ]
  }
}
```

The `install.sh` script copies skill and agent files but does not copy settings. Users may need to merge plugin settings into their own `.claude/settings.local.json` depending on their environment.

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
