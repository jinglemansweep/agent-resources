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
      role-python/
      role-nodejs/
      role-frontend/
      role-devops/
      role-docs/
      role-agent-skills/
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

**Artifacts:** `prompt.md` (user input), `prd.md` (product requirements document), `tasks.yaml` (structured task list), `state.yaml` (pipeline state), `changelog.md` (task execution log), `reviews/` (review artifacts and fix history), `summary.md` (final report)

**Skills:**

- `jp-setup` — Initialize the `.plans` directory structure for a project
- `jp-plan` — Create a new datestamped planning phase directory (`YYYY/MM/DD/NN-slug`) with branch setup, prompt review, and interactive gap resolution
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

- `role-python` — Python backend conventions and quality gates
- `role-nodejs` — Node.js/TypeScript conventions and quality gates
- `role-frontend` — Frontend/UI conventions and quality gates
- `role-devops` — Infrastructure and CI/CD conventions and quality gates
- `role-docs` — Documentation conventions and quality gates
- `role-agent-skills` — Skill authoring conventions and quality gates

**Agents:**

- `jp-worker-dev` — General-purpose developer agent that delegates to domain-specific skills. Examines task signals (file extensions, tools, frameworks) to automatically load the appropriate domain skill(s) and follows their conventions during implementation. Falls back to general software engineering practices when no domain matches.

### agentmap

AI-powered codebase orientation maps.

**Version:** 0.1.0

**Skills:**

- `agentmap-init` — Check for `.agentmap.yaml` and guide initial setup if missing
- `agentmap-read` — Teaches agents how to consume `.agentmap.yaml` codebase orientation maps
- `agentmap-generate` — Generate or update an `.agentmap.yaml` codebase orientation map

## Tutorial: Using the jplan Pipeline

This tutorial walks through the complete jplan planning pipeline from start to finish, covering each stage from initial setup to final summary.

### Prerequisites

Before starting, make sure you have the following in place:

- **Claude Code CLI** installed and configured on your system
- **A git repository** — the jplan pipeline requires git for branch management and phase tracking
- **The jplan plugin installed** — run `bash plugins/jplan/install.sh` to copy skills to `~/.claude/skills/` and agents to `~/.claude/agents/`

### Phase Directory Structure

Every planning phase lives in a date-stamped directory under `.plans/`. The naming convention is:

```text
.plans/YYYY/MM/DD/NN-slug/
```

- **YYYY/MM/DD** — the date the phase was created
- **NN** — a zero-padded sequence number (01, 02, ...) allowing multiple phases per day
- **slug** — a short, kebab-case label describing the work (e.g. `auth-refactor`)

For example, the first phase created on 1 March 2026 for an auth refactor would be:

```text
.plans/2026/03/01/01-auth-refactor/
```

Inside a phase directory, the pipeline generates and manages these artifacts:

```text
.plans/2026/03/01/01-auth-refactor/
├── prompt.md        # Your requirements (written by you or /jp-plan)
├── prd.md           # Product requirements document (generated by /jp-prd)
├── tasks.yaml       # Structured task list (generated by /jp-task-list)
├── state.yaml       # Pipeline execution state (managed by /jp-execute)
├── changelog.md     # Task execution log (appended by /jp-execute)
├── reviews/         # Review artifacts (PRD review, task review, code reviews)
└── summary.md       # Final report (generated by /jp-summary)
```

### Pipeline Overview

The jplan pipeline runs through eight stages in order. Each stage has a corresponding slash command:

| Stage | Command | Purpose |
|---|---|---|
| 1. Setup | `/jp-setup` | Initialize the `.plans` directory structure for the project |
| 2. Plan | `/jp-plan` | Create a new phase directory with branch setup and prompt authoring |
| 3. PRD | `/jp-prd` | Generate a product requirements document from the prompt |
| 4. PRD Review | `/jp-prd-review` | Review the PRD for coverage, contradictions, and feasibility |
| 5. Task List | `/jp-task-list` | Convert the approved PRD into a structured YAML task list |
| 6. Task Review | `/jp-task-review` | Validate task structure, dependencies, and PRD coverage |
| 7. Execute | `/jp-execute` | Process tasks sequentially with validation, code review, and fixes |
| 8. Summary | `/jp-summary` | Generate a final report covering tasks, reviews, and decisions |

### Step-by-Step Walkthrough

#### Stage 1: Initialize the Plans Directory (`/jp-setup`)

- **Command:** `/jp-setup`
- **What it does:** Creates the `.plans/` directory at the repository root if it does not exist. This is a one-time setup step per project.
- **Output:** `.plans/` directory created.
- **User interaction:** None — just run the command.

#### Stage 2: Create a Planning Phase (`/jp-plan`)

- **Command:** `/jp-plan <short-description>` (e.g. `/jp-plan auth-refactor`)
- **What it does:** Creates a new datestamped phase directory under `.plans/YYYY/MM/DD/NN-slug/`, creates a git branch (e.g. `feat/NN-slug`), and opens an interactive prompt session where the user describes what they want to build. The skill reviews the prompt for completeness and may ask clarifying questions to fill gaps. The result is saved as `prompt.md`.
- **Output:** Phase directory created with `prompt.md` inside it; git branch created.
- **User interaction:** The user writes or dictates their requirements. The skill may ask follow-up questions to resolve gaps in the prompt.

#### Stage 3: Generate the PRD (`/jp-prd`)

- **Command:** `/jp-prd <phase-path>` (e.g. `/jp-prd .plans/2026/03/01/01-auth-refactor`)
- **What it does:** Reads `prompt.md` and generates a structured Product Requirements Document with numbered requirements (`REQ-001`, `REQ-002`, ...), acceptance criteria, technical constraints, and scope boundaries.
- **Output:** `prd.md` in the phase directory.
- **User interaction:** None — the PRD is generated automatically from the prompt.

#### Stage 4: Review the PRD (`/jp-prd-review`)

- **Command:** `/jp-prd-review <phase-path>` (e.g. `/jp-prd-review .plans/2026/03/01/01-auth-refactor`)
- **What it does:** Critically evaluates the PRD against the original prompt for coverage gaps, contradictions, ambiguity, and feasibility. Produces a structured review with a verdict.
- **Output:** `reviews/prd.md` in the phase directory.
- **Review verdicts:** The review concludes with one of three verdicts:
  - **PASS** — The PRD is approved and ready for task breakdown. No action needed.
  - **REVISE** — Issues were found. The PRD is automatically revised and re-reviewed (up to a retry limit). No action needed.
  - **ESCALATE** — Fundamental issues require user input before proceeding. The user must address the raised concerns and re-run the review.
- **User interaction:** If the verdict is PASS or REVISE, no action is needed — the pipeline continues automatically. If the verdict is ESCALATE, review the issues listed in `reviews/prd.md`, update `prd.md` or `prompt.md` as needed, and re-run `/jp-prd-review`.

#### Stage 5: Generate the Task List (`/jp-task-list`)

- **Command:** `/jp-task-list <phase-path>` (e.g. `/jp-task-list .plans/2026/03/01/01-auth-refactor`)
- **What it does:** Reads the approved PRD and converts it into a structured YAML task list. Each task has an ID (`TASK-001`, `TASK-002`, ...), description, dependencies, a suggested domain role, and acceptance criteria. Tasks are topologically sorted by dependency so they can be executed in order.
- **Output:** `tasks.yaml` in the phase directory.
- **User interaction:** None — the task list is generated automatically.

#### Stage 6: Validate the Task List (`/jp-task-review`)

- **Command:** `/jp-task-review <phase-path>` (e.g. `/jp-task-review .plans/2026/03/01/01-auth-refactor`)
- **What it does:** Validates the task list for structural correctness, dependency ordering, and complete PRD requirement coverage. Produces a verdict of either PASS or REVISE.
- **Output:** `reviews/tasks.md` in the phase directory.
- **Review verdicts:**
  - **PASS** — The task list is valid and ready for execution. No action needed.
  - **REVISE** — Issues were found (dependency errors, coverage gaps, vague tasks, or invalid fields). Update `tasks.yaml` to address the action items (or re-run `/jp-task-list` to regenerate), then re-run `/jp-task-review`.
- **User interaction:** If the verdict is PASS, no action is needed. If the verdict is REVISE, review the issues in `reviews/tasks.md`, update `tasks.yaml` as needed, and re-run `/jp-task-review`.

#### Stage 7: Execute the Tasks (`/jp-execute`)

- **Command:** `/jp-execute <phase-path>` (e.g. `/jp-execute .plans/2026/03/01/01-auth-refactor`)
- **What it does:** The main orchestrator. Processes tasks sequentially in dependency order. For each task, it delegates to the `jp-worker-dev` agent, which examines task signals (file extensions, tools, frameworks) to automatically load the appropriate domain skill, and validates the output (`/jp-task-validate`). After all tasks complete, it enters a review-and-fix loop: performing code review (`/jp-codereview`) and applying fixes for critical and major issues (`/jp-codereview-fix`).
- **Output:** Modified project files as specified by tasks; `changelog.md` (append-only execution log); `state.yaml` (execution state for resumability); review artifacts in `reviews/`.
- **User interaction:** The execution runs autonomously. If a task fails validation or exceeds retry limits, the orchestrator may pause for user input.

> **Domain roles:** During execution, the developer agent automatically loads domain-specific skills based on what each task involves. For example, a Python implementation task loads `role-python`, a Docker task loads `role-devops`, and a documentation task loads `role-docs`. Available domain roles: `role-python`, `role-nodejs`, `role-frontend`, `role-devops`, `role-docs`, `role-agent-skills`. These are not invoked manually — the agent selects them based on task context.

#### Stage 8: Generate the Summary (`/jp-summary`)

- **Command:** `/jp-summary <phase-path>` (e.g. `/jp-summary .plans/2026/03/01/01-auth-refactor`)
- **What it does:** Generates a final report summarizing all completed tasks, review findings, fixes applied, and decisions made during the pipeline run.
- **Output:** `summary.md` in the phase directory.
- **User interaction:** None — the summary is generated automatically.

### Quick Pipeline (`/jp-quick`)

For cases where you want the full pipeline to run end-to-end with minimal interaction, `/jp-quick` orchestrates all eight stages (setup through summary) in a single invocation. It handles review verdicts automatically (retrying on REVISE, pausing on ESCALATE) and supports resumption if interrupted — it detects which stages have already completed and picks up where it left off.

```text
/jp-quick <description>       # Start a new phase (e.g. /jp-quick auth-refactor)
/jp-quick <phase-path>        # Resume an existing phase (e.g. /jp-quick .plans/2026/03/01/01-auth-refactor)
```

Use `/jp-quick` when you want a hands-off run from prompt to summary. Use the individual stage commands instead when you want to review or modify artifacts between stages — for example, editing the PRD before task breakdown, or adjusting the task list before execution.

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
