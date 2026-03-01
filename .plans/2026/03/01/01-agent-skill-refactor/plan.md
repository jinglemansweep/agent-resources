# Implementation Plan

> Source: `.plans/20260301/01-agent-skill-refactor/prompt.md`

## Overview

This plan delivers a refactored agent workflow orchestration system for automated software development. It replaces the current 7-skill pipeline (`jms-init` through `jms-execute`) with an expanded 12-skill pipeline that adds PRD review, task review, post-task validation, code review, automated fixing, and summary generation — plus a `state.yaml`-based resumability mechanism. Six new skills are created, three existing skills are substantially rewritten, one skill is removed, and the planner agent is updated to match the new pipeline.

## Architecture & Approach

The system is a linear pipeline of Claude Code skills, each producing artifacts in a phase directory under `.plans/`. The prompt defines 11 pipeline stages (New Phase → Plan → PRD Review → Task Breakdown → Task Review → Execute → Validate → Code Review → Fix → Summary), with Validate, Code Review, Fix, and Summary implemented as separate user-invocable skills that are primarily orchestrated by the Execute skill.

**Key architectural decisions from the prompt:**

- **Phase directory nesting changes** from the current flat `YYYYMMDD/NN-slug` to nested `YYYY/MM/DD/NN-slug`. This is a breaking change to the directory format.
- **Plan output changes** from three files (`plan.md`, `research.md`, `issues.md`) to a single PRD (`prd.md`). The current research and issues workflow is replaced by a PRD-centric approach.
- **Task format changes** from markdown checkboxes (`tasks.md`) to structured YAML (`tasks.yaml`) with explicit fields for dependencies, role suggestions, acceptance criteria, and complexity estimates.
- **`state.yaml`** is introduced as a new pipeline state tracking mechanism, enabling resumption after interruption.
- **The Execute skill becomes a full orchestrator** that manages state, delegates to role agents, runs validation after each task, and orchestrates a review & fix loop (up to 3 rounds) after all tasks complete.
- **Branch naming convention changes** from `plan/<slug>` to conventional prefixes (`feat/`, `fix/`, `chore/`, `refactor/`, `docs/`, `test/`) based on the phase description.
- **Configuration is embedded** in the Execute skill's `SKILL.md` as plain text instructions rather than parsed from external config files.
- **Role agents remain external** — the existing `jms-role-*` agents are unchanged and continue to be invoked by the orchestrator.

**Relationship to existing system:**

The current system has 7 skills and 7 agents. After this refactor:
- 3 skills are rewritten in place (`jms-phase-new`, `jms-plan`, `jms-execute`)
- 1 skill is rewritten, renamed, and format-changed (`jms-taskify` → `jms-task-breakdown` — output changes from markdown to YAML)
- 1 skill is removed (`jms-review` — replaced by `jms-prd-review` and `jms-task-review`)
- 6 new skills are created
- 2 skills are unchanged (`jms-init`, `jms-git-push`)
- 6 role agents are unchanged
- 1 agent is updated (`jms-planner`)
- 1 agent is removed (`jms-executor` — superseded by the Execute skill)

All skills continue to live under `plugins/jinglemansweep/skills/` and are installed to `~/.claude/skills/` via `install.sh`. The `jms-` prefix is retained for all skills to maintain plugin naming conventions.

## Components

### Phase Management (`jms-phase-new`)

**Purpose:** Initialize a new phase directory for a workflow run, establishing the workspace before any other skill executes.

**Inputs:** A short description of the phase (provided as a command argument).

**Outputs:** A new directory at `.plans/YYYY/MM/DD/NN-DESCRIPTION/` containing `prompt.md` (with a structured template), `logs/` and `reviews/` subdirectories, and an initialized `state.yaml`.

**Notes:** This is a rewrite of the existing `jms-phase-new`. The major changes are:
- Directory format changes from `YYYYMMDD/NN-slug` to `YYYY/MM/DD/NN-slug` (nested year/month/day)
- Branch naming changes from `plan/<slug>` to conventional prefixes (`feat/`, `fix/`, `chore/`, etc.) derived from the description
- `prompt.md` is created with a structured template (Overview, Goals, Requirements, Constraints, Out of Scope, References) instead of being empty
- `logs/` and `reviews/` subdirectories are created
- `state.yaml` is initialized with status `pending`, the phase path, and the active branch name

### Plan Generation (`jms-plan`)

**Purpose:** Generate a Product Requirements Document (PRD) from the user's prompt, replacing the current three-file output with a single comprehensive PRD.

**Inputs:** A phase path containing `prompt.md`.

**Outputs:** `prd.md` in the phase directory — a structured PRD containing project overview, goals, functional requirements, non-functional requirements, technical constraints, scope boundaries, acceptance criteria, and suggested tech stack.

**Notes:** This is a substantial rewrite of the current `jms-plan`. The current skill generates three files (`research.md`, `plan.md`, `issues.md`) with component-level architecture. The new skill generates a single `prd.md` with requirement-level detail. Each requirement must have acceptance criteria. The research and issues analysis is replaced by a requirements-first approach. The current `jms-plan` skill's research step (web/GitHub searches, compatibility matrix, licence summary) is not present in the prompt's Plan spec — the focus shifts to requirements over research.

### PRD Review (`jms-prd-review`)

**Purpose:** Self-critique the PRD for completeness, consistency, and feasibility before implementation begins.

**Inputs:** A phase path containing `prd.md` and `prompt.md`.

**Outputs:** `prd-review.md` in the phase directory — a review report with coverage assessment, contradiction detection, ambiguity flags, missing edge cases, feasibility concerns, and a verdict (PASS / REVISE / ESCALATE).

**Notes:** This is a new skill. It replaces part of the current `jms-review`'s role (which was a general-purpose interactive issue resolver). The PRD Review is primarily automated self-critique rather than interactive. The optional human-in-the-loop gate adds interactivity when enabled. If the verdict is PASS, the pipeline can proceed to Task Breakdown. If REVISE, specific feedback is provided. If ESCALATE, the pipeline halts for human input.

### Task Breakdown (`jms-task-breakdown`)

**Purpose:** Convert the approved PRD into a structured, ordered task list suitable for execution.

**Inputs:** A phase path containing the approved `prd.md`.

**Outputs:** `tasks.yaml` in the phase directory — a YAML file where each task has an ID, title, description, PRD requirement references, dependency list, suggested role, acceptance criteria, complexity estimate, and affected files list.

**Notes:** This rewrites and renames the current `jms-taskify` (now `jms-task-breakdown`) which generates `tasks.md` (markdown checkboxes). The skill directory moves from `skills/jms-taskify/` to `skills/jms-task-breakdown/`. The output format changes from markdown to YAML, adding structured fields. The task ID format is `TASK-NNN`. Every PRD requirement must be covered by at least one task. Tasks are ordered topologically by dependencies. The `suggested_role` field maps to the existing role agents (python, node, devops, etc.).

### Task Review (`jms-task-review`)

**Purpose:** Validate the task list structure, ordering, and completeness before execution.

**Inputs:** A phase path containing `tasks.yaml` and `prd.md`.

**Outputs:** `task-review.md` in the phase directory — a report with dependency validation (DAG check), ordering check, coverage check (all PRD requirements mapped), scope check (task sizing), and a verdict (PASS / REVISE).

**Notes:** This is a new skill. It performs structural validation that the current system doesn't have: building the dependency graph, checking for circular dependencies, simulating execution order, and verifying that every PRD requirement maps to at least one task. The verdict REVISE returns specific task IDs and what needs to change.

### Execution Orchestrator (`jms-execute`)

**Purpose:** Iterate through the task list in dependency order, delegate to role agents, manage pipeline state, and orchestrate the post-execution review & fix loop.

**Inputs:** A phase path containing `tasks.yaml` and `prd.md`. Reads and writes `state.yaml` for resumability.

**Outputs:** Implemented files in the project, per-task execution logs in `logs/`, review reports in `reviews/`, `fix-ledger.yaml`, and `summary.md`.

**Notes:** This is the largest and most complex rewrite. The current `jms-execute` works per-group (one markdown heading section per invocation), uses `tasks.md`, and delegates to role agents via the Task tool. The new version:
- Processes tasks sequentially by dependency order from `tasks.yaml` (parallel execution deferred to future)
- Maintains `state.yaml` as a single source of truth for pipeline progress
- Runs the Validate skill after each task
- After all tasks complete, enters the Review & Fix Loop (Code Review → Fix → Validate → repeat, max 3 rounds)
- Tracks fixes in `fix-ledger.yaml`
- Generates `summary.md` at the end
- Supports resumption from the last known state if interrupted
- The configuration (human approval gates, max fix rounds, max retries, available agents, validation checks) is embedded directly in the SKILL.md

The orchestrator invokes the Validate, Code Review, Fix, and Summary skills as sub-stages. Each is a separate, user-invocable SKILL.md that can also be run independently for ad-hoc use.

### Validation (`jms-validate`)

**Purpose:** Run automated checks on task output immediately after implementation.

**Inputs:** Files created or modified by the current task.

**Outputs:** A validation report (PASS or FAIL with file, line number, and description).

**Notes:** This is a new user-invocable skill, primarily invoked by the Execute orchestrator but also usable standalone. Checks include syntax validation/linting, type checking, unit tests, import/dependency resolution, and file structure verification. Only checks relevant to the file types involved are run. The skill does not attempt to fix issues — it reports them back.

### Code Review (`jms-code-review`)

**Purpose:** Holistic review of the codebase after all tasks execute, or scoped review of changed files after a fix round.

**Inputs:** The full codebase (first run) or changed files only (subsequent fix rounds), plus task context from the phase directory.

**Outputs:** `reviews/round-N.yaml` in the phase directory — a YAML file listing issues with ID, severity (CRITICAL/MAJOR/MINOR), category, file, line, description, suggestion, and related tasks.

**Notes:** This is a new user-invocable skill, primarily invoked by the Execute orchestrator but also usable standalone. It focuses on integration points between components — the most common gap in task-by-task execution. Severity levels drive the fix loop: CRITICAL and MAJOR trigger fixes; MINOR issues are logged but never trigger a fix round. In fix rounds, only changed files are re-reviewed.

### Fix (`jms-fix`)

**Purpose:** Apply corrections based on code review feedback.

**Inputs:** CRITICAL and MAJOR issues from the latest review round, affected files, and original task context.

**Outputs:** Corrected files and a fix report listing changes and the issue IDs they address.

**Notes:** This is a new user-invocable skill, primarily invoked by the Execute orchestrator but also usable standalone. It addresses only the issues provided — no unrelated refactoring. If an issue requires significant architectural changes, it is flagged as DEFERRED rather than attempted. Every change is logged with the issue ID it addresses.

### Summary (`jms-summary`)

**Purpose:** Generate a final report of the entire workflow run.

**Inputs:** All logs, review reports, and the fix ledger from the phase directory.

**Outputs:** `summary.md` in the phase directory — a markdown report with project overview, task status, files created/modified, review rounds summary, known issues, decisions log, and suggested next steps.

**Notes:** This is a new user-invocable skill, primarily invoked by the Execute orchestrator at the end of the pipeline (after the review & fix loop exits). It consolidates all artifacts into a single readable summary.

### Pipeline State (`state.yaml`)

**Purpose:** Track pipeline progress as a single source of truth, enabling resumption after interruption.

**Inputs:** Initialized by `jms-phase-new`, updated by `jms-execute` throughout the pipeline.

**Outputs:** A YAML file in the phase directory tracking overall status, current phase, branch, current task, per-task status/agent/retries, fix round number, and timestamps.

**Notes:** This is a cross-cutting concern rather than a standalone skill. The schema is defined in the prompt. The Execute orchestrator reads state.yaml on start to determine where to resume, and updates it after each significant state change (task completion, phase transition, fix round).

### Planner Agent (`jms-planner`)

**Purpose:** Guide the user through the full planning workflow — init, phase creation, plan generation, reviews, and task list generation.

**Inputs:** User conversation.

**Outputs:** Orchestrated invocation of planning skills and user guidance.

**Notes:** The existing `jms-planner` agent needs to be updated to reflect the new pipeline stages. The current workflow is: init → phase → plan → hand off for review → taskify. The new workflow is: init → phase → plan → PRD review → task breakdown → task review → hand off for execution. The agent still hands off interactive steps (PRD review with human gate) to the user.

### Metadata & Documentation

**Purpose:** Keep plugin metadata and project documentation in sync with the refactored skill set.

**Inputs:** The completed skill and agent files.

**Outputs:** Updated `plugin.json` (new skills added, `jms-review` removed) and updated `README.md` (documentation reflecting new pipeline).

**Notes:** The `install.sh` script copies `skills/*` and `agents/*` wholesale, so it does not need modification for new skill directories. The `plugin.json` skills array must list all skills. The README.md directory tree and skill documentation must be updated.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `plugins/jinglemansweep/skills/jms-phase-new/SKILL.md` | Modify | Rewrite with nested date format, template prompt.md, state.yaml init, conventional branch prefixes, logs/reviews subdirs |
| `plugins/jinglemansweep/skills/jms-plan/SKILL.md` | Modify | Rewrite to generate prd.md instead of plan.md + research.md + issues.md |
| `plugins/jinglemansweep/skills/jms-prd-review/SKILL.md` | Create | PRD review/critique skill with PASS/REVISE/ESCALATE verdicts |
| `plugins/jinglemansweep/skills/jms-taskify/SKILL.md` | Delete | Removed — renamed to jms-task-breakdown |
| `plugins/jinglemansweep/skills/jms-task-breakdown/SKILL.md` | Create | Replaces jms-taskify; produces tasks.yaml (structured YAML) instead of tasks.md (markdown checkboxes) |
| `plugins/jinglemansweep/skills/jms-task-review/SKILL.md` | Create | Task list DAG validation and coverage checking skill |
| `plugins/jinglemansweep/skills/jms-execute/SKILL.md` | Modify | Major rewrite as full orchestrator with state.yaml, validate/review/fix loop, embedded config |
| `plugins/jinglemansweep/skills/jms-validate/SKILL.md` | Create | Post-task automated validation skill (lint, type check, tests) |
| `plugins/jinglemansweep/skills/jms-code-review/SKILL.md` | Create | Holistic code review skill with severity-based issue reporting |
| `plugins/jinglemansweep/skills/jms-fix/SKILL.md` | Create | Issue-targeted fix application skill |
| `plugins/jinglemansweep/skills/jms-summary/SKILL.md` | Create | Final workflow summary report generation skill |
| `plugins/jinglemansweep/skills/jms-review/SKILL.md` | Delete | Replaced by jms-prd-review and jms-task-review |
| `plugins/jinglemansweep/agents/jms-planner.md` | Modify | Update workflow steps to match new pipeline stages |
| `plugins/jinglemansweep/agents/jms-executor.md` | Delete | Superseded by the Execute skill; agent is redundant |
| `plugins/jinglemansweep/plugin.json` | Modify | Add 6 new skills, rename jms-taskify to jms-task-breakdown, remove jms-review from skills array, remove jms-executor from agents array |
| `README.md` | Modify | Update directory tree and documentation for new/changed skills |
