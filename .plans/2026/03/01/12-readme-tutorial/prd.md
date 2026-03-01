# Product Requirements Document

> Source: `.plans/2026/03/01/12-readme-tutorial/prompt.md`

## Project Overview

Update the project README to include a comprehensive end-to-end tutorial demonstrating the full `jplan` plugin workflow. The tutorial will guide users through each pipeline stage — from project setup and prompt authoring through PRD generation, task breakdown, execution, and summary — so that new users can understand and adopt the planning pipeline without external documentation.

## Goals

- Provide a self-contained, step-by-step tutorial that walks a user through the entire `jplan` pipeline from start to finish
- Make the `jplan` plugin accessible to new users who have no prior experience with the planning pipeline
- Keep the README as the single source of truth for plugin usage documentation

## Functional Requirements

### REQ-001: End-to-End Tutorial Section

**Description:** The README must contain a new section that walks through the complete `jplan` pipeline in sequential order, covering each user-invocable skill from `/jp-setup` through `/jp-summary`.

**Acceptance Criteria:**

- [ ] A new tutorial section exists in the README with a clear heading (e.g. "Tutorial: Using the jplan Plugin")
- [ ] The tutorial covers every user-facing pipeline stage: setup, plan, prd, prd-review, task-list, task-review, execute, and summary
- [ ] Each stage includes the slash command to invoke it and a brief description of what it does and what it produces

### REQ-002: Pipeline Stage Descriptions

**Description:** Each pipeline stage in the tutorial must explain the purpose of the stage, the input it expects, the output it produces, and what the user should do at that point.

**Acceptance Criteria:**

- [ ] Each stage description includes the slash command syntax (e.g. `/jp-plan <description>`)
- [ ] Each stage description names the artifact(s) produced (e.g. `prompt.md`, `prd.md`, `tasks.yaml`)
- [ ] Each stage description explains any user interaction required (e.g. writing prompt content, responding to review verdicts)

### REQ-003: Quick Pipeline Reference

**Description:** The tutorial must mention `/jp-quick` as an alternative that runs the full pipeline in a single invocation, for users who prefer an automated flow.

**Acceptance Criteria:**

- [ ] The tutorial includes a reference to `/jp-quick` with a brief explanation of what it automates
- [ ] The reference clarifies when `/jp-quick` is appropriate versus running stages individually

### REQ-004: Phase Directory Structure Explanation

**Description:** The tutorial must explain the `.plans/YYYY/MM/DD/NN-slug/` directory convention and the artifacts that accumulate during a pipeline run.

**Acceptance Criteria:**

- [ ] The tutorial shows the phase directory naming format with an example
- [ ] A file tree or listing shows the key artifacts within a phase directory (`prompt.md`, `prd.md`, `tasks.yaml`, `state.yaml`, `changelog.md`, `reviews/`, `summary.md`)

### REQ-005: Prerequisites Section

**Description:** The tutorial must state what the user needs before starting (installed plugin, git repository, Claude Code CLI).

**Acceptance Criteria:**

- [ ] Prerequisites are listed before the first tutorial step
- [ ] The prerequisites mention running the plugin's `install.sh` to install skills and agents
- [ ] The prerequisites mention being inside a git repository

### REQ-006: Domain Roles Explanation

**Description:** The tutorial must briefly explain that domain role skills (`role-python`, `role-nodejs`, etc.) are automatically loaded by the developer agent during execution based on task signals, and do not need to be invoked manually.

**Acceptance Criteria:**

- [ ] The tutorial mentions domain roles in the context of the execution stage
- [ ] It is clear that domain roles are automatic and not user-invoked

### REQ-007: Review Verdict Flow

**Description:** The tutorial must explain the review verdict system (PASS, REVISE, ESCALATE) used by `/jp-prd-review` and `/jp-task-review`, and what the user should expect at each verdict.

**Acceptance Criteria:**

- [ ] The three verdict types are named and briefly defined
- [ ] The tutorial explains that REVISE triggers a retry and ESCALATE requires user input

### REQ-008: README Structure Consistency

**Description:** The new tutorial section must integrate cleanly into the existing README structure without disrupting or duplicating existing content.

**Acceptance Criteria:**

- [ ] The tutorial section is placed after the existing plugin descriptions and before the Installation section, or in another logical position that maintains document flow
- [ ] No existing content is removed or contradicted by the tutorial
- [ ] The tutorial uses the same Markdown style and heading hierarchy as the rest of the README

## Non-Functional Requirements

### REQ-009: Readability and Clarity

**Category:** Maintainability

**Description:** The tutorial must be written in clear, concise language that a developer with no prior knowledge of the `jplan` plugin can follow without confusion.

**Acceptance Criteria:**

- [ ] Each tutorial step can be understood independently without requiring the reader to cross-reference other sections
- [ ] Technical jargon is kept to a minimum; where used, it is explained on first occurrence
- [ ] The tutorial uses consistent formatting (code blocks for commands, inline code for file names and slash commands)

### REQ-010: Accuracy

**Category:** Reliability

**Description:** All commands, file paths, artifact names, and workflow descriptions in the tutorial must be accurate and match the current state of the `jplan` plugin skills.

**Acceptance Criteria:**

- [ ] Every slash command shown in the tutorial matches the actual skill name and usage syntax
- [ ] Every artifact file name matches what the corresponding skill actually produces
- [ ] The pipeline order shown matches the actual execution order in `/jp-quick`

### REQ-011: Markdown Lint Compliance

**Category:** Maintainability

**Description:** The updated README must pass the project's existing markdownlint configuration without new violations.

**Acceptance Criteria:**

- [ ] Running `pre-commit run markdownlint --files README.md` produces no errors

## Technical Constraints and Assumptions

### Constraints

- The README is a single Markdown file (`README.md`) at the repository root
- The project uses markdownlint with custom rules defined in `.markdownlint.yaml` (MD013, MD024, MD033, MD041 disabled)
- The GPL-3.0 license file must not be modified
- No new files should be created — all changes are to the existing `README.md`

### Assumptions

- Users have Claude Code CLI installed and configured
- Users have basic familiarity with git and command-line tools
- The `jplan` plugin has been installed via `install.sh` before attempting the tutorial

## Scope

### In Scope

- Adding a new tutorial section to `README.md` covering the end-to-end `jplan` pipeline
- Minor restructuring of existing README sections if needed for logical flow
- Ensuring the tutorial is accurate against current skill definitions

### Out of Scope

- Changes to any skill SKILL.md files or agent definitions
- Creating separate documentation files (e.g. a `docs/` directory or dedicated tutorial file)
- Modifying the `jplan` plugin's functionality or behavior
- Tutorial content for the `jinglemansweep` or `agentmap` plugins
- Screenshots or visual diagrams

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Documentation format | GitHub-Flavored Markdown | Specified by project — README.md is GFM |
| Linting | markdownlint (via pre-commit) | Existing project tooling |
