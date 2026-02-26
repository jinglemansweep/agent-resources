# agent-resources

![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)

A personal Claude Code agent and skill toolkit. Currently hosts the `jinglemansweep` plugin.

Licensed under GPL-3.0.

## Directory Structure

```text
marketplace.json            # Marketplace metadata listing available plugins
plugins/                    # Directory containing all plugins
  jinglemansweep/               # The jinglemansweep plugin
    plugin.json             # Plugin metadata (name, version, skills, agents)
    install.sh              # Installation script
    skills/                 # Skill definitions
      jms-init/
      jms-phase-new/
      jms-plan/
      jms-review/
      jms-taskify/
      jms-execute/
    agents/                 # Agent definitions
      jms-planner.md
      jms-role-general.md
      jms-role-python.md
      jms-role-nodejs.md
      jms-role-frontend.md
      jms-role-devops.md
      jms-role-docs.md
LICENSE                     # GPL-3.0 license
README.md                   # This file
```

## Plugins

### jinglemansweep

Personal Skills and Agents.

**Version:** 0.2.0

**Skills:**

- `jms-init` — Initialize the `.plans` directory structure for a project
- `jms-phase-new` — Create a new datestamped planning phase directory with sequential numbering
- `jms-plan` — Generate a high-level implementation plan, research, and issues from a prompt file
- `jms-review` — Review and resolve issues in a plan directory through interactive user decisions
- `jms-taskify` — Generate a detailed, actionable task list from an existing plan
- `jms-execute` — Implement tasks from a task list with quality gates and git commits per group

**Agents:**

- `jms-planner` — Guides the full planning workflow: init, phase selection, plan creation, issue review, and task list generation
- `jms-role-general` — General-purpose implementation specialist for mixed or unclassified tasks
- `jms-role-python` — Python backend implementation specialist
- `jms-role-nodejs` — JavaScript/TypeScript/Node implementation specialist
- `jms-role-frontend` — Frontend/UI implementation specialist
- `jms-role-devops` — Infrastructure and CI/CD implementation specialist
- `jms-role-docs` — Documentation implementation specialist

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

Plugins may include their own `.claude/settings.local.json` with plugin-specific settings. The `jinglemansweep` plugin includes a settings file at `plugins/jinglemansweep/.claude/settings.local.json` which configures automatic permission for the `jms-init` skill:

```json
{
  "permissions": {
    "allow": [
      "Skill(jms-init)"
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
