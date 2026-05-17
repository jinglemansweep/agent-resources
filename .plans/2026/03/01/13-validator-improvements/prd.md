# Product Requirements Document

> Source: `.plans/2026/03/01/13-validator-improvements/prompt.md`

## Project Overview

The `jp-task-validate` skill currently routes file validation by extension to appropriate linters and syntax checkers. Markdown files (`.md`) and YAML files (`.yaml`, `.yml`) are recognized but lack dedicated linting tools -- Markdown has no specific linter, and YAML only uses Python's `yaml` module for basic syntax parsing. This phase adds proper linter routing: `markdownlint` for Markdown files and `yamllint` for YAML files, following the same detection-before-use pattern the skill already applies to other tools.

## Goals

- Improve Markdown validation by routing `.md` files through `markdownlint` when available.
- Improve YAML validation by routing `.yaml`/`.yml` files through `yamllint` when available, providing richer diagnostics than bare syntax parsing.
- Maintain the existing tool-detection pattern: detect availability first, skip gracefully if the tool is not installed.

## Functional Requirements

### REQ-001: Markdownlint Integration

**Description:** When validating `.md` files, the skill must check for `markdownlint` (or `markdownlint-cli` / `markdownlint-cli2`) availability and run it against each Markdown file if present.

**Acceptance Criteria:**

- [ ] During the tool-detection step, the skill checks whether `markdownlint` (or its CLI variants) is available on the system PATH or as a project-local dependency.
- [ ] If `markdownlint` is detected, `.md` files are validated through it during the syntax/linting step.
- [ ] Markdownlint errors are captured and included in the validation report.
- [ ] If `markdownlint` is not available, `.md` file validation falls back to the existing behavior (no linter-specific checks) without producing an error.

### REQ-002: Yamllint Integration

**Description:** When validating `.yaml` or `.yml` files, the skill must check for `yamllint` availability and run it against each YAML file if present, in addition to or replacing the current basic syntax check.

**Acceptance Criteria:**

- [ ] During the tool-detection step, the skill checks whether `yamllint` is available on the system PATH or as a project-local dependency.
- [ ] If `yamllint` is detected, `.yaml`/`.yml` files are validated through it during the syntax/linting step.
- [ ] Yamllint errors are captured and included in the validation report.
- [ ] If `yamllint` is not available, YAML validation falls back to the existing Python `yaml` module syntax check without producing an error.

### REQ-003: Configuration File Detection

**Description:** The tool-detection step must recognize standard configuration files for `markdownlint` and `yamllint` as signals of tool availability and project intent.

**Acceptance Criteria:**

- [ ] Markdownlint config detection recognizes `.markdownlint.yaml`, `.markdownlint.yml`, `.markdownlint.json`, `.markdownlint-cli2.yaml`, and `.markdownlintrc`.
- [ ] Yamllint config detection recognizes `.yamllint`, `.yamllint.yaml`, and `.yamllint.yml`.
- [ ] Presence of a config file is logged/noted in the tool detection output.

### REQ-004: Validation Report Output

**Description:** Linting results from `markdownlint` and `yamllint` must integrate into the existing validation report format.

**Acceptance Criteria:**

- [ ] Markdownlint and yamllint findings appear in the same report structure as other linter results (errors, warnings, file paths, line numbers where available).
- [ ] Linter failures from `markdownlint` or `yamllint` contribute to a FAIL verdict following the existing verdict logic.
- [ ] The report identifies which tool produced each finding.

## Non-Functional Requirements

### REQ-005: Graceful Degradation

**Category:** Reliability

**Description:** The skill must never fail or produce an error status due to the absence of `markdownlint` or `yamllint`. Missing tools are a normal condition.

**Acceptance Criteria:**

- [ ] If neither `markdownlint` nor `yamllint` is installed, the skill behaves identically to the current version with no additional warnings or errors.
- [ ] If a tool is detected but execution fails (e.g. broken installation), the error is captured in the report but does not crash the validation run.

### REQ-006: Consistency with Existing Patterns

**Category:** Maintainability

**Description:** The implementation must follow the same patterns used for existing tool integrations (Ruff, ESLint, Shellcheck, etc.) in the skill definition.

**Acceptance Criteria:**

- [ ] Tool detection follows the same check pattern (project files, config files, PATH availability) as existing tools.
- [ ] Linting invocation and output capture follow the same structural pattern as existing linter integrations.
- [ ] No new validation step categories are introduced -- results are reported within the existing syntax/linting step.

## Technical Constraints and Assumptions

### Constraints

- Changes are limited to `plugins/jplan/skills/jp-task-validate/SKILL.md` -- the skill is a single Markdown instruction file, not executable code.
- The skill must not require installation of `markdownlint` or `yamllint` -- it only uses them if already available.
- The existing validation report format and verdict logic must not change.

### Assumptions

- `markdownlint` refers to the Node.js-based `markdownlint-cli` or `markdownlint-cli2` tool invoked via CLI.
- `yamllint` refers to the Python-based `yamllint` tool invoked via CLI.
- Both tools produce human-readable output on stdout/stderr suitable for capture and inclusion in reports.

## Scope

### In Scope

- Adding `markdownlint` detection and routing for `.md` files in `jp-task-validate`.
- Adding `yamllint` detection and routing for `.yaml`/`.yml` files in `jp-task-validate`.
- Adding configuration file detection for both tools.
- Integrating results into the existing validation report format.

### Out of Scope

- Installing `markdownlint` or `yamllint` as part of the validation process.
- Adding linters for other file types not mentioned in the prompt.
- Modifying the validation report format or verdict logic beyond integrating new tool results.
- Adding `markdownlint` or `yamllint` configuration files to this project.

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Markdown linting | markdownlint-cli / markdownlint-cli2 | Specified by prompt; industry-standard Markdown linter |
| YAML linting | yamllint | Specified by prompt; industry-standard YAML linter |
