# Implementation Plan

> Source: `.plans/20260226/04-role-agents/prompt.md`

## Overview

Update all role agents to enforce mandatory quality gates after every unit of work. Additionally, rewrite `jms-role-python` with virtualenv enforcement, recommended packages, project patterns, and differentiated behaviour for new vs existing projects. Each role agent gets shared quality gates (`pre-commit` if configured) plus domain-specific gates.

## Architecture & Approach

All six role agent Markdown files will be updated. The existing structure (YAML frontmatter → heading → intro → Domain Expertise → Constraints) is expanded to add a Quality Gates section and update Constraints across all agents. `jms-role-python` gets the most extensive changes with additional sections.

Key design choices:

1. **Quality gates are mandatory for all role agents** — every agent gets a "Quality Gates" section specifying what to run after each unit of work. Shared gates (`pre-commit` if configured) apply to all. Domain-specific gates vary by role.

2. **Duplicate runs with executor are acceptable** — the executor may also run quality gates. Both running them is explicitly preferred over either skipping them.

3. **Python agent gets the deepest treatment** — mandatory virtualenv enforcement, recommended packages, project patterns, and new vs existing project behaviour. Other agents get quality gates but no equivalent environment-setup sections (those can be added in future phases).

4. **Recommended packages and patterns are advisory, not mandatory** — they guide the Python agent's choices when applicable but don't override existing project decisions. Kept directly in the agent definition file.

5. **Constraints section updated across all agents** — the old "Do NOT run quality gates — the caller handles that" line is removed from every role agent and replaced with the mandatory quality gate behaviour.

## Components

### Mandatory Requirements Section

**Purpose:** Establish non-negotiable rules that override all other behaviour — virtualenv activation and quality gate execution.
**Inputs:** None — these are unconditional rules.
**Outputs:** Agent behaviour guarantees.
**Notes:** Placed immediately after the intro paragraph, before Domain Expertise, so the agent processes these constraints first. Uses strong imperative language (MUST, NEVER, NON-NEGOTIABLE) to ensure compliance. Covers both virtualenv creation (new projects) and discovery/activation (existing projects).

### New Projects Section

**Purpose:** Define the full scaffolding workflow when the agent is working on a brand-new Python project.
**Inputs:** User's project requirements.
**Outputs:** A properly scaffolded project with `pyproject.toml`, `.python-version`, `pre-commit` config, `.venv`, and installed dependencies.
**Notes:** Specifies `uv` for package management, `ruff` for linting/formatting. Virtualenv creation and activation must happen before any other work. Quality gates run after every unit of work.

### Existing Projects Section

**Purpose:** Define the discovery and adaptation workflow when the agent joins an existing Python codebase.
**Inputs:** Existing project files and structure.
**Outputs:** Agent operates within the project's existing conventions after activating its virtualenv.
**Notes:** Agent must search for `.venv` or `venv` and activate before any operations. Quality gates (if they exist) run after every unit of work.

### Recommended Packages Section

**Purpose:** Provide a curated list of preferred packages so the agent makes consistent technology choices.
**Inputs:** Task requirements.
**Outputs:** Package selection guidance.
**Notes:** Advisory, not mandatory — the agent should prefer these when applicable but respect existing project choices. Packages: Pydantic, Click, FastAPI, SQLAlchemy, Alembic, PAHO MQTT.

### Patterns Section

**Purpose:** Encode structural and architectural conventions for Python projects.
**Inputs:** Task requirements and project context.
**Outputs:** Consistent project structure and code organisation.
**Notes:** Covers: `pyproject.toml` as single config, top-level module, Pydantic for all models (co-located in one package), Pydantic-based configuration (defaults → env vars → CLI args), Click-based CLI module, mock objects for offline testing, unit tests with minimum coverage.

### Updated Domain Expertise Section

**Purpose:** Retain existing Python expertise guidance, updated to align with the new conventions.
**Inputs:** N/A.
**Outputs:** Agent knowledge scope.
**Notes:** Keep existing items (type hints, async, PEP 8, etc). Adjust packaging line to prioritise `uv` and `pyproject.toml`. Mention `ruff` explicitly as the linter/formatter.

### Updated Constraints Section (All Agents)

**Purpose:** Define operational boundaries, updated to reflect that agents now own quality gates.
**Inputs:** N/A.
**Outputs:** Behavioural limits.
**Notes:** Remove "Do NOT run quality gates — the caller handles that" from all role agents. Keep all other constraints (no git commits, no refactoring beyond tasks, tasks.md as source of truth).

### Quality Gates Section (jms-role-general)

**Purpose:** Add mandatory quality gates for the general-purpose agent.
**Inputs:** Project configuration.
**Outputs:** Validated code after each unit of work.
**Notes:** Shared gates only: run `pre-commit` if configured. No domain-specific gates since this agent handles mixed/unclassified tasks.

### Quality Gates Section (jms-role-nodejs)

**Purpose:** Add mandatory quality gates for the Node.js agent.
**Inputs:** Project configuration and test runner.
**Outputs:** Validated code after each unit of work.
**Notes:** Shared: `pre-commit` if configured. Domain-specific: `npm run test` (or equivalent: `yarn test`, `pnpm test`, `bun test`) — match the project's package manager and test script.

### Quality Gates Section (jms-role-frontend)

**Purpose:** Add mandatory quality gates for the frontend agent.
**Inputs:** Project configuration and test runner.
**Outputs:** Validated code after each unit of work.
**Notes:** Shared: `pre-commit` if configured. Domain-specific: `npm run test` (or equivalent) if tests exist, `npm run build` to verify no build breakage.

### Quality Gates Section (jms-role-devops)

**Purpose:** Add mandatory quality gates for the DevOps agent.
**Inputs:** Project configuration and IaC tool.
**Outputs:** Validated infrastructure code after each unit of work.
**Notes:** Shared: `pre-commit` if configured. Domain-specific: `terraform validate`/`terraform fmt` for Terraform projects, `ansible-lint` for Ansible, shell scripts via `shellcheck` if available.

### Quality Gates Section (jms-role-docs)

**Purpose:** Add mandatory quality gates for the docs agent.
**Inputs:** Project configuration.
**Outputs:** Validated documentation after each unit of work.
**Notes:** Shared: `pre-commit` if configured. No additional domain-specific gates — documentation changes are validated through pre-commit hooks (markdownlint, etc.) if present.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `plugins/jinglemansweep/agents/jms-role-python.md` | Modify | Rewrite with mandatory virtualenv/quality gates, recommended packages, patterns, new/existing project sections |
| `plugins/jinglemansweep/agents/jms-role-general.md` | Modify | Add quality gates section, update constraints |
| `plugins/jinglemansweep/agents/jms-role-nodejs.md` | Modify | Add quality gates section, update constraints |
| `plugins/jinglemansweep/agents/jms-role-frontend.md` | Modify | Add quality gates section, update constraints |
| `plugins/jinglemansweep/agents/jms-role-devops.md` | Modify | Add quality gates section, update constraints |
| `plugins/jinglemansweep/agents/jms-role-docs.md` | Modify | Add quality gates section, update constraints |
