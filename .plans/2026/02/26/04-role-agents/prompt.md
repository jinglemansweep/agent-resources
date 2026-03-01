# Improve Python Role Agent

Enhance the `jms-role-python` agent with stronger conventions for both new and existing Python projects.

## Mandatory Requirements

**Virtualenvs and quality gates are NON-NEGOTIABLE. The agent MUST enforce these in every scenario — no exceptions, no skipping, no deferring.**

- **Virtualenv**: Never run Python operations outside a virtualenv. Always create or activate one before any other work.
- **Quality gates**: Always run quality gates (`pre-commit`, `pytest`) after every unit of work. Never skip them, even for "small" changes.

## Recommended Packages

Prefer these packages when applicable:

- **Pydantic** — data models and configuration
- **Click** — CLI interfaces
- **FastAPI** — web APIs
- **SQLAlchemy** — database ORM
- **Alembic** — database migrations
- **PAHO MQTT** — MQTT messaging

## Patterns

- Always create `pyproject.toml` as the single project configuration file
- Create a top-level module/package for the project
- All data models must use Pydantic and live in the same module/package
- All configuration via Pydantic with precedence: defaults → env vars → command-line args
- Add a separate `cli` module using Click if the project needs a CLI
- Create mock objects for offline testing (Claude Code Web)
- Create applicable unit tests for new features, ensuring minimum coverage

## New Projects

When starting a new Python project, the agent MUST:

- Use `uv` for package management and `ruff` for linting/formatting
- Create a `pyproject.toml` as the single project configuration file
- Use the `.python-version` file convention to pin the Python version
- Create a `pre-commit` configuration covering linting, typing, etc.
- **MANDATORY**: Create and activate a virtualenv at `<project-root>/.venv`, then install all dependencies and local modules before doing anything else
- **MANDATORY**: Run quality gates (`pre-commit`, `pytest`) after each unit of work — never skip

## Existing Projects

When working on an existing Python project, the agent MUST:

- **MANDATORY**: Search for and activate the virtualenv (`.venv` or `venv`) before performing any operations — never run outside a virtualenv
- **MANDATORY**: Run existing quality gates (`pre-commit`, `pytest`) if they exist after each unit of work — never skip
