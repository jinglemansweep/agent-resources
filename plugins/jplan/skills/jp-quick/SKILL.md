---
name: jp-quick
description: End-to-end planning pipeline orchestration from prompt to summary
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

<!-- tags: workflow, pipeline, orchestration, planning, end-to-end -->
<!-- category: planning-tools -->

# jp-quick

Orchestrate the full planning-to-summary pipeline in a single invocation. Runs each stage in order, handles review verdicts, and supports resumption if interrupted.

## Usage

```text
/jp-quick [phase-path-or-description]
```

**Argument:**

- `[phase-path-or-description]` -- Either an existing phase directory path (e.g. `.plans/2026/03/01/01-auth-refactor`) or a short description for a new phase (e.g. "auth-refactor"). If it looks like a path (contains `/` or `.plans`), treat it as an existing phase. Otherwise, treat it as a description for a new phase.

If omitted, the skill lists the 5 most recent phase directories and prompts the user to select one, or offers to create a new phase.

## Pipeline Stages

| Stage | Skill | Purpose |
|-------|-------|---------|
| 1 | `/jp-setup` | Ensure `.plans/` directory exists |
| 2 | `/jp-plan` | Create a new phase directory (skipped if using existing phase) |
| 3 | `/jp-prd` | Generate PRD from `prompt.md` |
| 4 | `/jp-prd-review` | Review the PRD |
| 5 | `/jp-task-list` | Convert PRD to task list |
| 6 | `/jp-task-review` | Validate the task list |
| 7 | `/jp-execute` | Execute all tasks |
| 8 | `/jp-summary` | Generate final summary report |

## Instructions

### Step 0: Determine Repository Root

Run `git rev-parse --show-toplevel` to determine the repository root. All `.plans/` references in this skill resolve relative to this root (i.e. `<repo-root>/.plans/`). If the command fails (not a git repository), stop and tell the user this skill requires a git repository.

### Step 1: Resolve Input

If an argument was provided:

- **Existing phase path**: If the argument contains `/` or starts with `.plans`, verify the directory exists. If it does, skip to Step 3 (determine resume point). If it does not exist, stop and tell the user.
- **New phase description**: If the argument is a short description (no `/`), proceed to Step 2 to create a new phase.

If no argument was provided:

1. Scan `<repo-root>/.plans/` recursively for directories matching `NN-*` that contain a `prompt.md` or `tasks.yaml` file.
2. Sort by path in reverse lexicographic order.
3. Display the 5 most recent phase directories and offer two options:
   - Select an existing phase to resume.
   - Enter a description to create a new phase.
4. If no phase directories exist, ask the user for a phase description and proceed to Step 2.

### Step 2: Initialize and Create Phase

**Stage 1 -- Init:** Run `/jp-setup` to ensure the `.plans/` directory exists. Report: "Stage 1/8: Initializing .plans directory..."

**Stage 2 -- New phase:** Run `/jp-plan <description>` with the user's description. Record the returned phase path. Report: "Stage 2/8: Created phase at `<phase-path>`"

After phase creation, remind the user to write their requirements in `<phase-path>/prompt.md` before continuing. Wait for the user to confirm that `prompt.md` is ready.

### Step 3: Determine Resume Point

Read `<phase-path>/state.yaml` if it exists. Check for existing artifacts to determine which stages have already completed:

| Artifact | Indicates |
|----------|-----------|
| `prompt.md` exists | Ready for Stage 3 |
| `prd.md` exists | Stage 3 complete |
| `prd-review.md` exists with PASS verdict | Stage 4 complete |
| `tasks.yaml` exists | Stage 5 complete |
| `task-review.md` exists with PASS verdict | Stage 6 complete |
| `state.yaml` has `status: completed` | Stage 7 complete |
| `summary.md` exists | Stage 8 complete (all done) |

Skip stages that already have valid output. Report which stages are being skipped.

If `state.yaml` has `status: running` or `status: review_loop`, Stage 7 (`/jp-execute`) will handle its own resumption internally.

### Step 4: Generate PRD (Stage 3)

Report: "Stage 3/8: Generating PRD..."

Run `/jp-prd <phase-path>`.

### Step 5: Review PRD (Stage 4)

Report: "Stage 4/8: Reviewing PRD..."

Run `/jp-prd-review <phase-path>`.

Read the output `<phase-path>/prd-review.md` and check the verdict:

- **PASS**: Continue to Step 6.
- **REVISE**: Report the action items to the user. Re-run `/jp-prd <phase-path>` to regenerate the PRD incorporating the feedback, then re-run `/jp-prd-review <phase-path>`. Repeat up to 2 times. If still REVISE after 2 retries, escalate to the user.
- **ESCALATE**: Stop and present the flagged issues to the user. Wait for the user to resolve them manually and confirm before continuing.

### Step 6: Generate Task List (Stage 5)

Report: "Stage 5/8: Breaking down PRD into tasks..."

Run `/jp-task-list <phase-path>`.

### Step 7: Review Task List (Stage 6)

Report: "Stage 6/8: Reviewing task list..."

Run `/jp-task-review <phase-path>`.

Read the output `<phase-path>/task-review.md` and check the verdict:

- **PASS**: Continue to Step 8.
- **REVISE**: Report the action items to the user. Re-run `/jp-task-list <phase-path>` to regenerate the task list incorporating the feedback, then re-run `/jp-task-review <phase-path>`. Repeat up to 2 times. If still REVISE after 2 retries, escalate to the user.

### Step 8: Execute Tasks (Stage 7)

Report: "Stage 7/8: Executing tasks..."

Run `/jp-execute <phase-path>`.

This stage handles its own resumption internally via `state.yaml`. It also runs the review-and-fix loop and produces the summary as part of its pipeline. If `/jp-execute` completes successfully (including its internal summary generation), skip Step 9.

### Step 9: Generate Summary (Stage 8)

Report: "Stage 8/8: Generating summary..."

Run `/jp-summary <phase-path>` only if `/jp-execute` did not already generate a summary.

### Step 10: Report

Present the final status to the user:

- **Phase path**: `<phase-path>`
- **Stages completed**: list which stages ran vs. which were skipped
- **Summary report**: `<phase-path>/summary.md`
- **Next steps**: Suggest reviewing the summary and optionally pushing commits and creating a pull request.

## Guidelines

- **Delegate, do not implement.** This skill orchestrates by invoking other `/jp-*` skills. It does not generate PRDs, break down tasks, or execute implementations itself.
- **Respect review verdicts.** PASS means continue. REVISE means regenerate and re-review. ESCALATE means stop and involve the user. Do not skip or override review verdicts.
- **Limit retries.** Do not retry a REVISE loop more than 2 times. After 2 failed retries, escalate to the user rather than looping indefinitely.
- **Report progress.** Always print the stage number and description before running each stage so the user knows where the pipeline is.
- **Support resumption.** Check for existing artifacts before running each stage. Do not regenerate output that already exists and has passed review.
- **Wait for user input.** After creating a new phase, wait for the user to confirm that `prompt.md` is ready before generating the PRD. After an ESCALATE verdict, wait for the user to resolve the issues before continuing.
