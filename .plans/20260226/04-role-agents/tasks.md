# Task List

> Source: `.plans/20260226/04-role-agents/plan.md`

## Python Role Agent Rewrite

### Mandatory Requirements & Environment

- [x] **Add Mandatory Requirements section to `plugins/jinglemansweep/agents/jms-role-python.md`** — Insert a new `## Mandatory Requirements` section immediately after the intro paragraph (line 8) and before `## Domain Expertise`. Content must state two non-negotiable rules using strong imperative language:
  1. **Virtualenv**: "NEVER run Python operations outside a virtualenv. For new projects, create `.venv` at the project root and activate it before any other work. For existing projects, search for `.venv` or `venv` and activate it before any operations."
  2. **Quality gates**: "ALWAYS run quality gates (`pre-commit` if configured, `pytest` if tests exist) after every unit of work. Never skip them, even for small changes. Duplicate runs with the executor are acceptable — both running is preferred over either skipping."

- [x] **Add New Projects section to `plugins/jinglemansweep/agents/jms-role-python.md`** — Insert a `## New Projects` section after `## Mandatory Requirements`. Content must define the scaffolding workflow as a checklist-style set of rules:
  - Use `uv` for package management and `ruff` for linting/formatting
  - Create `pyproject.toml` as the single project configuration file
  - Use `.python-version` file to pin the Python version
  - Create a `pre-commit` configuration covering linting, formatting, typing
  - **MANDATORY**: Create and activate a virtualenv at `<project-root>/.venv`, install all dependencies and local modules before doing anything else
  - **MANDATORY**: Run quality gates (`pre-commit`, `pytest`) after each unit of work

- [x] **Add Existing Projects section to `plugins/jinglemansweep/agents/jms-role-python.md`** — Insert a `## Existing Projects` section after `## New Projects`. Content must define the discovery and adaptation workflow:
  - **MANDATORY**: Search for and activate the virtualenv (`.venv` or `venv`) before performing any operations — never run outside a virtualenv
  - Respect existing project conventions, tooling, and structure
  - **MANDATORY**: Run existing quality gates (`pre-commit`, `pytest`) if configured, after each unit of work

### Recommended Packages & Patterns

- [x] **Add Recommended Packages section to `plugins/jinglemansweep/agents/jms-role-python.md`** — Insert a `## Recommended Packages` section after `## Existing Projects`. Include an introductory line stating these are advisory (prefer when applicable, respect existing project choices). List:
  - **Pydantic** — data models and configuration
  - **Click** — CLI interfaces
  - **FastAPI** — web APIs
  - **SQLAlchemy** — database ORM
  - **Alembic** — database migrations
  - **PAHO MQTT** — MQTT messaging

- [x] **Add Patterns section to `plugins/jinglemansweep/agents/jms-role-python.md`** — Insert a `## Patterns` section after `## Recommended Packages`. List these structural and architectural conventions:
  - `pyproject.toml` as the single project configuration file
  - Create a top-level module/package for the project
  - All data models use Pydantic and live in the same module/package
  - All configuration via Pydantic with precedence: defaults → env vars → CLI args
  - Separate `cli` module using Click if the project needs a CLI
  - Create mock objects for offline testing
  - Create applicable unit tests for new features with minimum coverage targets

### Domain Expertise & Quality Gates

- [x] **Update Domain Expertise section in `plugins/jinglemansweep/agents/jms-role-python.md`** — Modify the existing `## Domain Expertise` section. Keep all current items (type hints, async, PEP 8, etc.) but make these adjustments:
  - Change the packaging line from `Packaging: pyproject.toml, setup.cfg, pip, poetry, uv` to `Packaging: pyproject.toml with uv (preferred), pip, poetry — use what the project uses`
  - Change the formatter line from `Follow PEP 8 and existing project style (formatter config like ruff, black)` to `Follow PEP 8 and existing project style; use ruff for linting and formatting`

- [x] **Add Quality Gates section to `plugins/jinglemansweep/agents/jms-role-python.md`** — Insert a `## Quality Gates` section after `## Domain Expertise` and before `## Constraints`. State that these run after every unit of work, no exceptions:
  - Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
  - Run `pytest` (or the project's test command) if tests exist
  - If either gate fails, fix the issue before moving on

### Constraints Update

- [x] **Update Constraints section in `plugins/jinglemansweep/agents/jms-role-python.md`** — In the `## Constraints` section, remove the line `- Do NOT run quality gates (linting, tests, builds) — the caller handles that`. Keep all other constraint lines unchanged:
  - Implement ONLY the given tasks, mark each done (`- [x]`) in tasks.md
  - Complete subtasks before marking parent tasks done
  - Stop and report if a task is unclear or impossible to implement as described
  - Do NOT make git commits — the caller handles that
  - Do NOT refactor or improve code beyond what the tasks specify
  - `tasks.md` descriptions are the sole source of truth — do not reference other planning files

## Other Role Agents — Quality Gates & Constraints

### jms-role-general

- [ ] **Add Quality Gates section to `plugins/jinglemansweep/agents/jms-role-general.md`** — Insert a `## Quality Gates` section after `## Domain Expertise` and before `## Constraints`. Content: "After every unit of work, run the following gates. Do not skip them." List:
  - Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
  - If the gate fails, fix the issue before moving on
  - No additional domain-specific gates (this agent handles mixed/unclassified tasks)

- [ ] **Update Constraints section in `plugins/jinglemansweep/agents/jms-role-general.md`** — Remove the line `- Do NOT run quality gates (linting, tests, builds) — the caller handles that` from the `## Constraints` section. Keep all other constraint lines unchanged.

### jms-role-nodejs

- [ ] **Add Quality Gates section to `plugins/jinglemansweep/agents/jms-role-nodejs.md`** — Insert a `## Quality Gates` section after `## Domain Expertise` and before `## Constraints`. Content: "After every unit of work, run the following gates. Do not skip them." List:
  - Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
  - Run `npm run test` (or `yarn test`, `pnpm test`, `bun test` — match the project's package manager and test script) if tests exist
  - If any gate fails, fix the issue before moving on

- [ ] **Update Constraints section in `plugins/jinglemansweep/agents/jms-role-nodejs.md`** — Remove the line `- Do NOT run quality gates (linting, tests, builds) — the caller handles that` from the `## Constraints` section. Keep all other constraint lines unchanged.

### jms-role-frontend

- [ ] **Add Quality Gates section to `plugins/jinglemansweep/agents/jms-role-frontend.md`** — Insert a `## Quality Gates` section after `## Domain Expertise` and before `## Constraints`. Content: "After every unit of work, run the following gates. Do not skip them." List:
  - Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
  - Run `npm run test` (or equivalent, matching the project's package manager) if tests exist
  - Run `npm run build` (or equivalent) to verify no build breakage
  - If any gate fails, fix the issue before moving on

- [ ] **Update Constraints section in `plugins/jinglemansweep/agents/jms-role-frontend.md`** — Remove the line `- Do NOT run quality gates (linting, tests, builds) — the caller handles that` from the `## Constraints` section. Keep all other constraint lines unchanged.

### jms-role-devops

- [ ] **Add Quality Gates section to `plugins/jinglemansweep/agents/jms-role-devops.md`** — Insert a `## Quality Gates` section after `## Domain Expertise` and before `## Constraints`. Content: "After every unit of work, run the following gates. Do not skip them." List:
  - Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
  - For Terraform projects: run `terraform validate` and `terraform fmt -check`
  - For Ansible projects: run `ansible-lint` if available
  - For shell scripts: run `shellcheck` if available
  - If any gate fails, fix the issue before moving on

- [ ] **Update Constraints section in `plugins/jinglemansweep/agents/jms-role-devops.md`** — Remove the line `- Do NOT run quality gates (linting, tests, builds) — the caller handles that` from the `## Constraints` section. Keep all other constraint lines unchanged.

### jms-role-docs

- [ ] **Add Quality Gates section to `plugins/jinglemansweep/agents/jms-role-docs.md`** — Insert a `## Quality Gates` section after `## Domain Expertise` and before `## Constraints`. Content: "After every unit of work, run the following gates. Do not skip them." List:
  - Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists (this covers markdownlint and other doc-related hooks)
  - If the gate fails, fix the issue before moving on
  - No additional domain-specific gates

- [ ] **Update Constraints section in `plugins/jinglemansweep/agents/jms-role-docs.md`** — Remove the line `- Do NOT run quality gates (linting, tests, builds) — the caller handles that` from the `## Constraints` section. Keep all other constraint lines unchanged.
