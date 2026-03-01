---
name: jms-execute
description: Full pipeline orchestrator — executes tasks, validates, reviews, fixes, and generates a summary report
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Task
---

# jms-execute

Full pipeline orchestrator for executing a phase's task list. Processes tasks sequentially in dependency order, delegates each to the appropriate role agent, validates outputs, runs a review-and-fix loop, and generates a final summary report. Supports resumability via `state.yaml`.

## Usage

```text
/jms-execute [phase-path]
```

**Argument:**

- `[phase-path]` -- (Optional) Path to the phase directory (e.g. `.plans/2026/03/01/01-auth-implementation`). This directory must contain `tasks.yaml` and `prd.md`.

If omitted, the skill lists the 5 most recent phase directories and prompts the user to select one (see Step 1).

**Directory convention:**

```text
<phase-path>/
├── prompt.md           <- context (original requirements)
├── prd.md              <- input (approved PRD)
├── tasks.yaml          <- input (task list from jms-task-breakdown)
├── state.yaml          <- input/output (execution state)
├── fix-ledger.yaml     <- output (fix round history)
├── logs/
│   ├── task-001.md     <- output (per-task execution logs)
│   ├── task-002.md
│   └── ...
├── reviews/
│   ├── round-1.yaml    <- output (code review rounds)
│   ├── round-2.yaml
│   └── ...
└── summary.md          <- output (final report from jms-summary)
```

## Orchestrator Configuration

The following configuration values govern orchestrator behaviour. They are embedded here and must not be moved to a separate file.

```yaml
# Human-in-the-loop gates
pause_after_prd_review: false
pause_after_task_review: false

# Execution limits
max_fix_rounds: 3
max_retries_per_task: 1
include_minor_in_fix_loop: false

# Available role agents
agents:
  python:
    agent: jms-role-python
    signals: [".py", "pytest", "django", "fastapi", "flask", "pyproject.toml", "pip", "poetry", "uv"]
  nodejs:
    agent: jms-role-nodejs
    signals: [".js", ".ts", "npm", "pnpm", "express", "vitest", "jest", "package.json", "node"]
  frontend:
    agent: jms-role-frontend
    signals: [".jsx", ".tsx", ".vue", ".css", ".scss", ".html", "react", "tailwind", "component", "styled"]
  devops:
    agent: jms-role-devops
    signals: ["Dockerfile", "docker-compose", ".github/workflows/", "terraform", "ansible", "CI/CD", "pipeline", ".yml workflow"]
  docs:
    agent: jms-role-docs
    signals: [".md documentation", "README", "changelog", "API docs", "writing documentation"]
  general:
    agent: jms-role-general
    signals: []

# Validation checks (delegated to /jms-validate)
validation_checks:
  - linting
  - type_checking
  - tests
  - import_resolution
  - file_structure

# Summary output
summary_format: markdown
summary_include_fix_ledger: true
summary_include_decision_log: true
```

## Instructions

### Step 1: Resolve Phase Path

If a phase path argument was provided, use it directly. Verify that the directory exists. If it does not exist, stop and tell the user.

If no argument was provided:

1. Scan `.plans/` recursively for directories matching the pattern `NN-*` (where NN is a two-digit number) that contain a `tasks.yaml` file.
2. Sort by path in reverse lexicographic order (most recent date and highest increment first).
3. Display the 5 most recent phase directories and ask the user to select one.
4. If no qualifying phase directories are found, stop and tell the user to run `/jms-task-breakdown` first to generate a task list.

### Step 2: Validate Inputs

Verify the phase directory contains the required files:

1. `tasks.yaml` -- If missing, stop and tell the user to run `/jms-task-breakdown` first.
2. `prd.md` -- If missing, stop and tell the user to run `/jms-plan` first.
3. `state.yaml` -- If missing, stop and tell the user to run `/jms-phase-new` first.

Verify that the `logs/` and `reviews/` subdirectories exist inside the phase directory. Create them if they do not exist.

### Step 3: Read Inputs and Determine Resume Point

Read the following files:

1. `<phase-path>/tasks.yaml` -- The task list. Parse all tasks with their IDs, titles, descriptions, requirements, dependencies, suggested roles, acceptance criteria, complexity estimates, and files affected.
2. `<phase-path>/prd.md` -- The Product Requirements Document. Use this for context when delegating to role agents.
3. `<phase-path>/state.yaml` -- The execution state.

**Resumability:** Examine `state.yaml` to determine whether this is a fresh run or a resumed run:

- If `state.yaml` has `status: pending` or `status: running` with no `tasks` section, this is a fresh run. Start from the first task.
- If `state.yaml` has `status: running` and contains a `tasks` section with per-task statuses, this is a resumed run. Find the first task whose status is not `completed` and resume from there. Tasks already marked `completed` in `state.yaml` are skipped.
- If `state.yaml` has `status: completed`, report that this phase has already finished and stop.
- If `state.yaml` has `status: review_loop`, resume at the Review & Fix Loop (Step 7).
- If `state.yaml` has `status: failed`, report the failure reason from state and ask the user whether to retry from the failed task or abort.

Update `state.yaml` immediately to record the start of execution:

```yaml
status: running
phase_path: <phase-path>
branch: <current-git-branch>
started_at: <ISO 8601 timestamp>
current_phase: task_execution
current_task: null
fix_round: 0
tasks: {}
```

Preserve any existing `tasks` entries from a prior run (for resumability).

### Step 4: Build Execution Order

Build the task execution order from `tasks.yaml`:

1. Perform a topological sort based on the `dependencies` field of each task.
2. Tasks with no dependencies come first.
3. Among tasks at the same dependency level, preserve the order from `tasks.yaml`.
4. If the dependency graph contains a cycle, stop and report the cycle to the user. Do not attempt execution with circular dependencies.

The result is an ordered list of task IDs to execute sequentially.

### Step 5: Execute Tasks

Process each task in the execution order determined in Step 4. For each task:

#### 5a: Skip Completed Tasks

If `state.yaml` already records this task as `completed`, skip it and move to the next task.

If `state.yaml` records this task as `blocked`, skip it (it failed in a prior run and its dependents will also be skipped).

#### 5b: Check Dependencies

Verify that all tasks in this task's `dependencies` list have status `completed` in `state.yaml`. If any dependency has status `failed` or `blocked`, mark this task as `blocked` in `state.yaml` with reason "dependency <TASK-NNN> is <status>", log it, and skip to the next task.

#### 5c: Update State

Update `state.yaml`:

```yaml
current_task: <TASK-NNN>
tasks:
  <TASK-NNN>:
    status: running
    agent: null
    retries: 0
    started_at: <ISO 8601 timestamp>
```

#### 5d: Select Role Agent

Determine the appropriate role agent for this task. Use the `suggested_role` field from `tasks.yaml` as the primary signal. Cross-reference with the task content (description, files_affected, acceptance_criteria) to confirm the role is appropriate.

**Role mapping:**

| `suggested_role` value | Agent name |
|---|---|
| `python` | `jms-role-python` |
| `nodejs` | `jms-role-nodejs` |
| `devops` | `jms-role-devops` |
| `frontend` | `jms-role-frontend` |
| `general` | `jms-role-general` |
| `docs` | `jms-role-docs` |

If the `suggested_role` does not match the task content (e.g. the role says `python` but the task only involves Dockerfiles), override with the better-fitting role based on the signals in the Orchestrator Configuration. If no clear role emerges, use `jms-role-general`.

Update `state.yaml` with the selected agent:

```yaml
tasks:
  <TASK-NNN>:
    agent: <selected-agent-name>
```

#### 5e: Delegate to Role Agent

Spawn the selected role agent using the `Task` tool with `subagent_type` set to `general-purpose`. Provide a prompt containing:

1. The agent identity (e.g. "You are acting as the jms-role-python agent.").
2. The `tasks.md` path set to `<phase-path>/tasks.yaml` (note: role agents read this for context).
3. The full task definition from `tasks.yaml`:
   - Task ID, title, and description.
   - Acceptance criteria.
   - Files affected.
   - Dependencies (for context on what was already built).
4. Relevant PRD context -- extract the sections of `prd.md` related to the requirements listed in this task's `requirements` field. Do not send the entire PRD unless the task touches most requirements.
5. A list of existing files in the project that are relevant to this task (from `files_affected` and dependency outputs).
6. Instruction to implement the task and confirm completion.

Example prompt structure:

```text
You are acting as the jms-role-python agent. Follow the instructions in your agent definition.

tasks.md path: <phase-path>/tasks.yaml
Group: ## Task Execution

Tasks to implement:
- [ ] **<TASK-NNN>: <title>** -- <description>
  Acceptance criteria:
  - <criterion 1>
  - <criterion 2>
  Files affected:
  - <file 1>
  - <file 2>

PRD Context:
<relevant PRD sections>

Existing relevant files:
<list of files from prior tasks>

Implement the task and confirm what files were created or modified.
```

**Fallback:** If the Task tool fails to spawn the role agent (error, agent not found, etc.), fall back to implementing the task directly using the available tools (Read, Edit, Write, Bash, Glob, Grep). Follow the same task definition and acceptance criteria.

#### 5f: Validate Output

After the role agent completes (or fallback implementation finishes), determine which files were created or modified by the task. Use the `files_affected` field from the task definition, supplemented by any additional files reported by the role agent.

Run `/jms-validate` on the output files:

```text
/jms-validate <file1> <file2> ...
```

**If validation returns `PASS`:** Proceed to Step 5g.

**If validation returns `FAIL`:** Allow one retry (per the `max_retries_per_task` configuration).

1. Update `state.yaml` to increment the retry count for this task.
2. Provide the validation error output to the role agent (or handle directly in fallback mode) with instructions to fix the specific issues reported.
3. After the retry, run `/jms-validate` again on the affected files.
4. If validation still fails after the retry, mark the task as `failed` and proceed to Step 5g.

#### 5g: Log the Result

Write a task log file to `<phase-path>/logs/task-NNN.md` (matching the task ID number, e.g. `task-001.md` for `TASK-001`):

```markdown
# Task Log: TASK-NNN

## Task

- **Title:** <title>
- **Role agent:** <agent used>
- **Status:** <completed | failed | blocked>
- **Retries:** <N>
- **Started:** <ISO 8601 timestamp>
- **Finished:** <ISO 8601 timestamp>

## Files

### Created

- `path/to/new/file.py`

### Modified

- `path/to/existing/file.py`

## Validation

- **Verdict:** <PASS | FAIL>
- **Issues:** <summary of validation issues, or "None">

## Notes

<Any additional notes about the execution -- decisions made, problems encountered, fallback used, etc.>
```

#### 5h: Update State

Update `state.yaml` with the task result:

```yaml
tasks:
  <TASK-NNN>:
    status: <completed | failed | blocked>
    agent: <agent-name>
    retries: <N>
    started_at: <ISO 8601 timestamp>
    finished_at: <ISO 8601 timestamp>
    validation: <PASS | FAIL>
```

If the task failed after retry, set status to `failed`. Subsequent tasks that depend on this task will be marked `blocked` in Step 5b.

#### 5i: Continue

Move to the next task in the execution order. Repeat from Step 5a.

### Step 6: Task Execution Complete

After all tasks have been processed (completed, failed, or blocked), update `state.yaml`:

```yaml
current_phase: review_loop
current_task: null
status: review_loop
tasks_completed_at: <ISO 8601 timestamp>
```

Report a brief interim summary to the user:

- Total tasks: N
- Completed: N
- Failed: N
- Blocked: N

If ALL tasks failed or were blocked, stop and report the failure. Do not enter the review loop with no successful work.

### Step 7: Review & Fix Loop

Enter the review-and-fix loop. This loop runs after all tasks are processed and iterates up to the configured `max_fix_rounds` (3).

#### 7a: Run Code Review

**Round 1:** Run `/jms-code-review` with scope `full`:

```text
/jms-code-review <phase-path> full
```

**Round 2+:** Run `/jms-code-review` with scope `changed`:

```text
/jms-code-review <phase-path> changed
```

The code review skill writes its findings to `<phase-path>/reviews/round-N.yaml`.

#### 7b: Evaluate Review Results

Read the review round file (`reviews/round-N.yaml`) and collect all issues by severity.

**Exit condition -- success:** If the review found zero CRITICAL and zero MAJOR issues, the review loop is complete. Proceed to Step 8.

**Exit condition -- minor only:** If the review found only MINOR issues, the review loop is complete. MINOR issues are logged in the summary but never trigger a fix round. Proceed to Step 8.

#### 7c: Run Fixes

If CRITICAL or MAJOR issues exist, run `/jms-fix`:

```text
/jms-fix <phase-path>
```

The fix skill reads the latest review round file, applies targeted corrections, and updates `fix-ledger.yaml`.

Update `state.yaml`:

```yaml
fix_round: <N>
```

#### 7d: Validate Fixes

After fixes are applied, determine which files were changed by reading the fix report from `/jms-fix`. Run `/jms-validate` on those files:

```text
/jms-validate <changed-file-1> <changed-file-2> ...
```

If validation fails, log the failure but continue to the next review round -- the review will catch the issues.

#### 7e: Check Loop Continuation

Before starting the next review round, check the exit conditions:

1. **Round limit reached:** If the current fix round equals `max_fix_rounds` (3), exit the loop. Log all remaining CRITICAL and MAJOR issues as known issues. Proceed to Step 8.

2. **Regression detected:** Compare the issue counts between the current round and the previous round. If the new review round has MORE new issues (issues not present in the previous round) than issues resolved, a regression has occurred. Exit the loop immediately. Log the regression in `state.yaml` and in the fix ledger. Proceed to Step 8.

3. **Otherwise:** Loop back to Step 7a for the next review round.

Update `state.yaml` after each round:

```yaml
fix_round: <N>
last_review_round: <N>
review_loop_exit_reason: null  # or "success", "round_limit", "regression"
```

#### 7f: Record Loop Exit

When the review loop exits, update `state.yaml`:

```yaml
current_phase: summary
review_loop_exit_reason: <success | round_limit | regression>
review_loop_completed_at: <ISO 8601 timestamp>
```

### Step 8: Generate Summary

Run `/jms-summary` to generate the final report:

```text
/jms-summary <phase-path>
```

This reads all logs, review reports, the fix ledger, tasks, and the PRD to produce `<phase-path>/summary.md`.

### Step 9: Finalize

Update `state.yaml` to mark the phase as complete:

```yaml
status: completed
completed_at: <ISO 8601 timestamp>
```

### Step 10: Report

Present the final report to the user:

- **Phase path:** `<phase-path>`
- **Overall status:** completed (or completed with issues)
- **Task execution:**
  - Total tasks: N
  - Completed: N
  - Failed: N
  - Blocked: N
- **Review & fix loop:**
  - Review rounds conducted: N
  - Total issues found: N (N CRITICAL, N MAJOR, N MINOR)
  - Issues fixed: N
  - Issues deferred: N
  - Issues remaining: N
  - Exit reason: success / round limit / regression
- **Summary report:** `<phase-path>/summary.md`
- **State file:** `<phase-path>/state.yaml`

If there are remaining CRITICAL or MAJOR issues, list them with their descriptions.

Ask the user whether they would like to:

1. Push commits and create a pull request.
2. Review the summary before proceeding.
3. Stop here.

If the user chooses to push and create a PR, follow the PR creation flow:

1. Push the current branch: `git push -u origin HEAD`
2. Create a PR using `gh pr create` with a title derived from the phase directory name (strip numeric prefix, convert kebab-case to readable title) and a body built from the summary.

## Guidelines

- **Sequential execution only.** Process tasks one at a time in dependency order. Parallel execution is not supported in this version.
- **Respect the dependency graph.** Never execute a task before all of its dependencies have completed. If a dependency failed, mark dependent tasks as blocked.
- **One retry maximum.** If a task fails validation after one retry, mark it as failed and move on to independent tasks. Do not retry indefinitely.
- **MINOR issues never trigger fixes.** MINOR issues from code review are logged in the summary but are never passed to `/jms-fix` and never cause additional review rounds.
- **Fix only what review finds.** The review-and-fix loop addresses issues found by `/jms-code-review`. Do not add extra fixes, refactoring, or improvements beyond what is reported.
- **Stop on regression.** If a fix round introduces more new issues than it resolves, stop the loop immediately. Continuing would make the codebase worse.
- **State is the source of truth.** Always read and update `state.yaml` before and after each operation. This enables resumability if the orchestrator is interrupted.
- **Log everything.** Every task execution produces a log file in `logs/`. Every review round produces a file in `reviews/`. Every fix round updates `fix-ledger.yaml`. The summary reads all of these to produce the final report.
- **Do not modify task definitions.** The orchestrator reads `tasks.yaml` but never modifies it. Task definitions are the output of `/jms-task-breakdown` and are immutable during execution.
- **Delegate, do not implement.** The orchestrator's role is coordination. Delegate implementation to role agents, validation to `/jms-validate`, review to `/jms-code-review`, fixes to `/jms-fix`, and reporting to `/jms-summary`.
