# Product Requirements Document

> Source: `.plans/2026/03/01/10-slim-state-persistence/prompt.md`

## Project Overview

The jplan pipeline currently persists excessive state during execution — per-task log files, verbose `state.yaml` entries with redundant timestamps and metadata, and review artifacts scattered across the phase root directory. This phase restructures the phase directory layout, consolidates review artifacts under `reviews/`, replaces per-task logs with a single `changelog.md`, slims `state.yaml` to minimal resumability fields, and removes backward-compatibility cleanup from `install.sh` scripts. The result is fewer tool calls, lower token consumption, and a cleaner directory structure.

## Goals

- Reduce tool calls and token usage during pipeline execution by eliminating per-task log file writes, per-task timestamp shell calls, and verbose state updates.
- Consolidate all review-related artifacts under a `reviews/` subdirectory for a cleaner phase directory layout.
- Slim `state.yaml` to contain only the fields required for execution resumability.
- Remove accumulated backward-compatibility cleanup sections from `install.sh` scripts.

## Functional Requirements

### REQ-001: Remove backward-compatibility cleanup from install.sh scripts

**Description:** Both `plugins/jplan/install.sh` and `plugins/jinglemansweep/install.sh` contain large sections of `rm -rf` and `rm -f` commands that clean up artifacts from previous naming schemes. These are no longer needed. Remove all cleanup sections, keeping only the core install logic (copy skills and agents to the destination directory, print confirmation).

**Acceptance Criteria:**

- [ ] `plugins/jplan/install.sh` contains no `rm -rf` or `rm -f` commands.
- [ ] `plugins/jinglemansweep/install.sh` contains no `rm -rf` or `rm -f` commands.
- [ ] Both scripts still correctly copy skills and agents to `${DEST}` and print an install confirmation.
- [ ] Both scripts pass `bash -n` syntax check.

### REQ-002: Update CLAUDE.md backward-compatibility rule

**Description:** The project `CLAUDE.md` contains the rule "Maintain backward compatibility with the `install.sh` script." This rule is no longer applicable since install scripts are used for development/testing only. Remove this rule and replace it with a note that install scripts are for local testing and do not need backward compatibility.

**Acceptance Criteria:**

- [ ] `CLAUDE.md` no longer contains the text "Maintain backward compatibility with the `install.sh` script."
- [ ] `CLAUDE.md` contains a replacement rule indicating install scripts are for local testing and do not require backward compatibility.

### REQ-003: Relocate review-related artifacts into reviews/ subdirectory

**Description:** Move review output files from the phase root into the `reviews/` subdirectory. The following relocations apply:

| Current path | New path |
|---|---|
| `prd-review.md` | `reviews/prd.md` |
| `task-review.md` | `reviews/tasks.md` |
| `fix-ledger.yaml` | `reviews/fixes.yaml` |

Files that stay in place: `prompt.md`, `prd.md`, `tasks.yaml`, `state.yaml`, `summary.md`, `changelog.md`.

**Acceptance Criteria:**

- [ ] Every skill that writes `prd-review.md` now writes to `reviews/prd.md` instead.
- [ ] Every skill that writes `task-review.md` now writes to `reviews/tasks.md` instead.
- [ ] Every skill that writes or reads `fix-ledger.yaml` now uses `reviews/fixes.yaml` instead.
- [ ] Every skill that reads these files for input uses the new paths.
- [ ] All directory convention diagrams in affected SKILL.md files reflect the new layout.

### REQ-004: Restructure code review cycle files with zero-padded naming

**Description:** Change the review round file naming convention from `reviews/round-N.yaml` to `reviews/cycle/NNN.yaml`, where `NNN` is a three-digit zero-padded index (e.g. `001.yaml`, `002.yaml`). The `reviews/cycle/` subdirectory must be created by `jp-plan` as part of the initial phase directory structure.

**Acceptance Criteria:**

- [ ] `jp-plan` creates `reviews/cycle/` when setting up a new phase directory.
- [ ] `jp-codereview` writes review round files to `reviews/cycle/NNN.yaml` (three-digit zero-padded).
- [ ] `jp-codereview-fix` reads review round files from `reviews/cycle/NNN.yaml`.
- [ ] `jp-execute` references `reviews/cycle/NNN.yaml` in its review-loop logic.
- [ ] `jp-summary` reads review round files from `reviews/cycle/NNN.yaml`.
- [ ] Round numbering counts existing files in `reviews/cycle/` to determine the next sequence number.

### REQ-005: Replace per-task log files with single changelog.md

**Description:** Remove the `logs/` subdirectory and per-task log files (`logs/task-NNN.md`). Replace them with a single `changelog.md` file in the phase root, appended to after each task completes. Each entry records the task ID, title, status, files created/modified, and implementation notes. The `logs/` directory is no longer created by `jp-plan`.

The changelog format per entry:

```markdown
## TASK-NNN: <title>

**Status:** completed | failed | blocked

### Files Created
- `path/to/file`

### Files Modified
- `path/to/file`

### Notes
<Implementation notes>

---
```

**Acceptance Criteria:**

- [ ] `jp-plan` no longer creates a `logs/` subdirectory.
- [ ] `jp-execute` no longer writes individual `logs/task-NNN.md` files.
- [ ] `jp-execute` appends an entry to `changelog.md` after each task completes (or is blocked/failed).
- [ ] `jp-summary` reads `changelog.md` instead of scanning `logs/task-*.md` files.
- [ ] `jp-execute` no longer references the `logs/` directory in its directory convention diagram or step instructions.
- [ ] `changelog.md` entries contain task ID, title, status, files created, files modified, and notes.

### REQ-006: Slim state.yaml to minimal resumability fields

**Description:** Reduce `state.yaml` to contain only the fields required for execution resumability. Remove per-task metadata (agent, retries, timestamps, validation result) and top-level timestamps. Per-task entries become a simple `TASK-NNN: <status>` mapping.

**Retained fields:**

```yaml
status: <pending | running | review_loop | completed | failed>
phase_path: <path>
branch: <branch-name>
current_phase: <task_execution | review_loop | quality_gate | completed>
current_task: <TASK-NNN | null>
fix_round: <N>
last_review_round: <N>
review_loop_exit_reason: <null | success | round_limit | regression>
quality_gate: <pass | fail>
tasks:
  TASK-001: <completed | failed | blocked | running>
  TASK-002: <completed | failed | blocked | running>
```

**Removed fields:**

- Per-task: `agent`, `retries`, `started_at`, `finished_at`, `validation`
- Top-level: `started_at`, `completed_at`, `tasks_completed_at`, `review_loop_completed_at`, `quality_gate_completed_at`
- `quality_gate_override` (override is already captured by the quality gate status flow)

**Acceptance Criteria:**

- [ ] `jp-plan` initial `state.yaml` contains only `status`, `phase_path`, and `branch`.
- [ ] `jp-execute` state updates write only the retained fields listed above.
- [ ] `jp-execute` does not run `date -u` shell commands for per-task timestamp capture.
- [ ] Per-task entries in `state.yaml` are simple `TASK-NNN: status` key-value pairs.
- [ ] Resumability still works: `jp-execute` can determine where to resume from the slim state.
- [ ] `jp-summary` can generate a complete summary from the slim `state.yaml` combined with `changelog.md`.

### REQ-007: Update jp-plan skill for new directory structure

**Description:** Update `jp-plan` SKILL.md to create the new directory layout and use the slim initial `state.yaml`.

**Acceptance Criteria:**

- [ ] Step 5 creates `reviews/` and `reviews/cycle/` subdirectories (not `logs/`).
- [ ] Step 7 creates `state.yaml` with only `status: pending`, `phase_path`, and `branch`.
- [ ] Step 8 report mentions `reviews/` and `reviews/cycle/` (not `logs/`).
- [ ] No references to `logs/` directory remain in the skill.

### REQ-008: Update jp-execute skill for new structure and slim state

**Description:** Update `jp-execute` SKILL.md to use the restructured directory layout, slim `state.yaml` format, `changelog.md` instead of per-task logs, and new review/fix-ledger paths. This is the largest change as jp-execute is the primary orchestrator.

**Acceptance Criteria:**

- [ ] Directory convention diagram reflects the new layout (no `logs/`, `reviews/cycle/NNN.yaml`, `reviews/fixes.yaml`, `changelog.md`).
- [ ] All `state.yaml` read/write examples use the slim format.
- [ ] Step 5g writes to `changelog.md` (append) instead of `logs/task-NNN.md`.
- [ ] Step 5h updates `state.yaml` with only `TASK-NNN: <status>`.
- [ ] Step 5c/5d no longer write `agent`, `retries`, or `started_at` to per-task state entries.
- [ ] Review-loop steps reference `reviews/cycle/NNN.yaml` instead of `reviews/round-N.yaml`.
- [ ] Fix-loop steps reference `reviews/fixes.yaml` instead of `fix-ledger.yaml`.
- [ ] Timestamp Convention section is removed or simplified (no per-task timestamps needed).
- [ ] Quality gate file collection uses `changelog.md` instead of `logs/` for file lists.
- [ ] The "Log everything" guideline is updated to reflect `changelog.md` and the new paths.

### REQ-009: Update jp-codereview skill for new file paths

**Description:** Update `jp-codereview` SKILL.md to write review files to `reviews/cycle/NNN.yaml` and read fix history from `reviews/fixes.yaml`.

**Acceptance Criteria:**

- [ ] Directory convention diagram shows `reviews/cycle/NNN.yaml` and `reviews/fixes.yaml`.
- [ ] Step 1 counts existing files in `reviews/cycle/` to determine the next round number.
- [ ] Step 2 reads `reviews/fixes.yaml` instead of `fix-ledger.yaml`.
- [ ] Step 2 reads previous rounds from `reviews/cycle/` instead of `reviews/round-*.yaml`.
- [ ] Step 8 writes output to `reviews/cycle/NNN.yaml`.
- [ ] No references to `round-N.yaml`, `fix-ledger.yaml`, or `logs/` remain.

### REQ-010: Update jp-codereview-fix skill for new file paths

**Description:** Update `jp-codereview-fix` SKILL.md to read review rounds from `reviews/cycle/NNN.yaml` and write the fix ledger to `reviews/fixes.yaml`.

**Acceptance Criteria:**

- [ ] Directory convention diagram shows `reviews/cycle/NNN.yaml` and `reviews/fixes.yaml`.
- [ ] Step 1 scans `reviews/cycle/` for `*.yaml` files to find the latest review.
- [ ] Step 2 reads `reviews/fixes.yaml` instead of `fix-ledger.yaml`.
- [ ] Step 6 writes to `reviews/fixes.yaml` instead of `fix-ledger.yaml`.
- [ ] Fix ledger `review_file` field references `reviews/cycle/NNN.yaml`.
- [ ] No references to `round-*.yaml`, `fix-ledger.yaml`, or `logs/` remain.

### REQ-011: Update jp-prd-review skill for new output location

**Description:** Update `jp-prd-review` SKILL.md to write its output to `reviews/prd.md` instead of `prd-review.md`.

**Acceptance Criteria:**

- [ ] Directory convention diagram shows `reviews/prd.md` as the output.
- [ ] Step 8 writes to `reviews/prd.md` instead of `prd-review.md`.
- [ ] All internal references to the output file use `reviews/prd.md`.
- [ ] No references to `prd-review.md` remain in the skill.

### REQ-012: Update jp-task-review skill for new output location

**Description:** Update `jp-task-review` SKILL.md to write its output to `reviews/tasks.md` instead of `task-review.md`.

**Acceptance Criteria:**

- [ ] Directory convention diagram shows `reviews/tasks.md` as the output.
- [ ] Step 9 writes to `reviews/tasks.md` instead of `task-review.md`.
- [ ] Step 2 reads `reviews/prd.md` (if referenced) instead of `prd-review.md`.
- [ ] All internal references to the output file use `reviews/tasks.md`.
- [ ] No references to `task-review.md` remain in the skill.

### REQ-013: Update jp-summary skill for new input paths

**Description:** Update `jp-summary` SKILL.md to read from the restructured paths: `changelog.md`, `reviews/prd.md`, `reviews/tasks.md`, `reviews/fixes.yaml`, and `reviews/cycle/NNN.yaml`.

**Acceptance Criteria:**

- [ ] Directory convention diagram reflects the new layout.
- [ ] Step 2 reads `changelog.md` instead of `logs/task-*.md` files.
- [ ] Step 2 reads `reviews/prd.md` instead of `prd-review.md`.
- [ ] Step 2 reads `reviews/tasks.md` instead of `task-review.md`.
- [ ] Step 2 reads `reviews/fixes.yaml` instead of `fix-ledger.yaml`.
- [ ] Step 6 reads `reviews/cycle/NNN.yaml` instead of `reviews/round-*.yaml`.
- [ ] Step 4 extracts file manifests from `changelog.md` instead of per-task logs.
- [ ] No references to `logs/`, `prd-review.md`, `task-review.md`, `fix-ledger.yaml`, or `round-*.yaml` remain.

### REQ-014: Update jp-quick skill for new resume-point detection

**Description:** Update `jp-quick` SKILL.md Step 3 resume-point detection to check for review artifacts at their new paths (`reviews/prd.md` and `reviews/tasks.md` instead of `prd-review.md` and `task-review.md`).

**Acceptance Criteria:**

- [ ] Step 3 resume-point table checks `reviews/prd.md` for Stage 4 completion.
- [ ] Step 3 resume-point table checks `reviews/tasks.md` for Stage 6 completion.
- [ ] Steps 5 and 7 read review verdicts from `reviews/prd.md` and `reviews/tasks.md`.
- [ ] No references to `prd-review.md` or `task-review.md` remain in the skill.

## Non-Functional Requirements

### REQ-015: Reduce per-task tool calls during execution

**Category:** Performance

**Description:** The combined changes (slim state, single changelog, removed timestamp calls) must measurably reduce the number of tool calls per task during `jp-execute` execution.

**Acceptance Criteria:**

- [ ] Per-task execution no longer requires a `date -u` Bash call for `started_at` or `finished_at`.
- [ ] Per-task state update writes a single key-value pair instead of a 6-line block.
- [ ] Task logging is a single append to `changelog.md` instead of creating a new file.

### REQ-016: Maintain execution resumability

**Category:** Reliability

**Description:** The slimmed `state.yaml` must still support all existing resumability scenarios: fresh run, resume from interrupted task execution, resume from review loop, resume from quality gate, and detection of completed phases.

**Acceptance Criteria:**

- [ ] `jp-execute` can resume from `status: running` by finding the first non-completed task in the `tasks` map.
- [ ] `jp-execute` can resume from `status: review_loop` by skipping directly to the review-fix loop.
- [ ] `jp-execute` can detect `status: completed` and refuse to re-execute.
- [ ] `jp-execute` can detect `status: failed` and offer retry options.

## Technical Constraints and Assumptions

### Constraints

- All changes are to Markdown skill files (`SKILL.md`) and shell scripts (`install.sh`, `CLAUDE.md`). No runtime code or external dependencies are involved.
- The phase directory structure is used only by the jplan pipeline skills. No external consumers depend on the current layout.
- Review cycle files use three-digit zero-padded numbering (`001.yaml`, `002.yaml`) as specified in the prompt.

### Assumptions

- The prompt references `task-review.yaml` but the current file is `task-review.md` (Markdown format). This PRD assumes the format stays Markdown and the new path is `reviews/tasks.md`.
- Existing `.plans/` directories from prior phases are not migrated. The new structure applies only to newly created phases.
- The `agentmap` plugin install script (`plugins/agentmap/install.sh`) has no backward-compatibility cleanup and requires no changes.

## Scope

### In Scope

- All `SKILL.md` files in the jplan plugin that reference phase directory paths.
- Both `install.sh` scripts (jplan and jinglemansweep).
- `CLAUDE.md` project rules.
- `jp-quick` resume-point detection.

### Out of Scope

- Migrating existing `.plans/` phase directories to the new structure.
- Changes to the agentmap plugin.
- Changes to `plugin.json` or `marketplace.json` metadata.
- Changes to the `jp-worker-dev` agent definition.
- Renaming skills or agents (naming was addressed in a prior phase).
- Changes to `README.md` (documentation updates are handled by the execution pipeline's documentation gate).
- Changes to `.agentmap.yaml` (updated separately if needed).

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Skill definitions | Markdown (SKILL.md) | Specified by project conventions |
| Install scripts | Bash | Specified by project conventions |
| State/review files | YAML | Existing convention for structured data |
| Changelog | Markdown | Human-readable append-only log |
