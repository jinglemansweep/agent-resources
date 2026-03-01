---
name: jms-plan-fix
description: Apply targeted corrections for CRITICAL and MAJOR code review issues
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

# jms-plan-fix

Apply targeted corrections to address CRITICAL and MAJOR issues identified by `/jms-plan-code-review`. This is a standalone, user-invocable skill primarily called by the `jms-plan-execute` orchestrator during the review-and-fix loop. It addresses only the issues provided -- no unrelated refactoring, no scope expansion.

## Usage

```text
/jms-plan-fix <phase-path>
```

**Argument:**

- `<phase-path>` -- Path to the phase directory (e.g. `.plans/2026/03/01/01-auth-implementation`). This directory must contain the latest review round file in `reviews/` and the original task context (`tasks.yaml`, `prd.md`).

**Directory convention:**

```text
<phase-path>/
├── prompt.md           <- context (original requirements)
├── prd.md              <- context (approved PRD)
├── tasks.yaml          <- context (task list)
├── reviews/
│   ├── round-1.yaml    <- input (review issues)
│   └── round-N.yaml    <- input (latest review -- primary input)
├── fix-ledger.yaml     <- output (created or appended by this skill)
├── logs/               <- created by jms-plan-phase-new
└── state.yaml          <- created by jms-plan-phase-new
```

## Instructions

### Step 0: Determine Repository Root

Run `git rev-parse --show-toplevel` to determine the repository root. All `.plans/` references in this skill resolve relative to this root (i.e. `<repo-root>/.plans/`). If the command fails (not a git repository), stop and tell the user this skill requires a git repository.

### Step 1: Validate Inputs

1. Verify that `<phase-path>` exists.
2. Verify that `tasks.yaml` and `prd.md` exist in the phase directory.
3. Scan `<phase-path>/reviews/` for review round files matching `round-*.yaml`. If none exist, stop and tell the user to run `/jms-plan-code-review` first.
4. Identify the latest review round file by sorting `round-*.yaml` files and selecting the highest-numbered one. This is the primary input.

### Step 2: Read Context

Read the following files:

1. The latest review round file (`reviews/round-N.yaml`) -- this contains the issues to fix.
2. `<phase-path>/tasks.yaml` -- for understanding the original task intent and file context.
3. `<phase-path>/prd.md` -- for understanding the project requirements.
4. `<phase-path>/fix-ledger.yaml` -- if it exists, read it to understand what was fixed in prior rounds and avoid regressions.

### Step 3: Filter Issues

From the latest review round file, extract only CRITICAL and MAJOR issues. Ignore MINOR issues entirely -- they are logged in the summary but never trigger fixes.

Build a work list of issues to address, ordered by:

1. CRITICAL issues first, then MAJOR issues.
2. Within each severity level, group issues that affect the same file together (to minimize context switches and ensure related changes are made together).

If there are no CRITICAL or MAJOR issues, report that no fixes are needed and stop.

### Step 4: Analyze Each Issue

For each issue in the work list, before making any changes:

1. Read the affected file and the specific lines referenced by the issue.
2. Understand the surrounding code context -- what the function does, what calls it, what it calls.
3. Cross-reference with the `related_tasks` field to understand the original implementation intent from `tasks.yaml`.
4. Determine whether the issue can be resolved with a targeted, scoped change, or whether it requires significant architectural changes.

**If an issue requires significant architectural changes** (e.g. redesigning a module interface, changing the data model, restructuring the dependency graph), do NOT attempt the fix. Instead, flag it as `DEFERRED` with a clear explanation of why it cannot be resolved in a targeted fix round and what broader changes would be needed.

### Step 5: Apply Fixes

For each non-deferred issue, apply the fix:

1. **Make the minimum change necessary** to resolve the issue. Do not refactor surrounding code, rename unrelated variables, add features, or improve code that is not part of the issue.
2. **Maintain existing code style and patterns.** Match the indentation, naming conventions, error handling approach, and module structure already used in the file. Do not impose a different style.
3. **If a fix requires changes to multiple files** (e.g. fixing an API contract mismatch requires updating both the caller and the callee), make all related changes together before moving to the next issue.
4. **If a fix could break other functionality**, check callers and dependents of the changed code. Verify that the fix does not introduce a new issue elsewhere. If it would, note the risk in the fix report.

As each fix is applied, record:

- The issue ID being addressed.
- The file(s) changed.
- A brief description of what was changed and why.

### Step 6: Update Fix Ledger

Create or update `<phase-path>/fix-ledger.yaml` to record this fix round. The ledger tracks the history of all fix rounds and their outcomes.

If the file does not exist, create it. If it exists, append the new round entry.

```yaml
# Fix ledger
# Phase: <phase-path>
# Maintained by: /jms-plan-fix

rounds:
  - round: N
    review_file: "reviews/round-N.yaml"
    issues_input: 5
    issues_fixed: 3
    issues_deferred: 1
    issues_remaining: 1
    regressions_introduced: 0
    exit_reason: "fixes_applied"
    fixes:
      - issue_id: "ISSUE-001"
        status: "fixed"
        files_changed:
          - "src/auth/handler.py"
          - "src/auth/service.py"
        description: "Added missing remember_me parameter to login endpoint call and updated UserService.authenticate() to default remember_me to False."

      - issue_id: "ISSUE-003"
        status: "deferred"
        files_changed: []
        description: "Requires redesigning the session management interface to support both cookie-based and token-based authentication. This is an architectural change beyond the scope of a targeted fix round."

      - issue_id: "ISSUE-004"
        status: "fixed"
        files_changed:
          - "src/api/routes.py"
        description: "Added try/except block around database query in get_user_profile() to catch connection errors and return a structured 503 response."
```

**Field requirements:**

- `round` -- The review round number this fix round addresses.
- `review_file` -- Relative path to the review file that produced the issues.
- `issues_input` -- Total number of CRITICAL and MAJOR issues from the review round.
- `issues_fixed` -- Number of issues successfully fixed.
- `issues_deferred` -- Number of issues flagged as DEFERRED.
- `issues_remaining` -- Number of issues not addressed (if any were skipped for reasons other than deferral). Should typically be 0.
- `regressions_introduced` -- Number of new issues introduced by the fixes (determined in the next review round -- set to 0 when writing, updated later if needed).
- `exit_reason` -- One of: `fixes_applied` (normal completion), `all_deferred` (every issue was deferred), `no_issues` (no CRITICAL/MAJOR issues to fix).
- `fixes` -- List of individual fix entries, each with `issue_id`, `status` (`fixed` or `deferred`), `files_changed`, and `description`.

### Step 7: Report

Present a fix report to the caller:

```text
Fix Report
==========

Round: N (addressing reviews/round-N.yaml)

Issues received:  <N> (N CRITICAL, N MAJOR)
Issues fixed:     <N>
Issues deferred:  <N>
Issues remaining: <N>

Fixed:
  - ISSUE-001 (CRITICAL) -> src/auth/handler.py, src/auth/service.py
    Added missing remember_me parameter to login endpoint call.
  - ISSUE-004 (MAJOR) -> src/api/routes.py
    Added error handling for database connection failures.

Deferred:
  - ISSUE-003 (MAJOR) -> Requires session management redesign.

Files changed:
  - src/auth/handler.py
  - src/auth/service.py
  - src/api/routes.py
```

After the report:

- If fixes were applied, note that `/jms-plan-validate` should be run on the changed files to verify the fixes do not introduce syntax or test failures.
- If all issues were deferred, note that no code changes were made and the deferred items should be logged as known issues in the project summary.

## Guidelines

- **Fix only what is reported.** Address the specific issues provided. Do not fix adjacent problems, refactor nearby code, or add improvements beyond the scope of the issue. Every change must trace back to an issue ID.
- **Maintain existing patterns.** Do not use a fix round as an opportunity to change coding style, rename variables unrelated to the issue, or restructure modules. Match what is already there.
- **Group related changes.** If an issue spans multiple files (e.g. an API contract mismatch), make all related changes together. Do not leave half of a cross-file fix incomplete.
- **Defer honestly.** If a fix genuinely requires architectural changes that cannot be made safely in a targeted fix round, defer it. Do not attempt a half-fix that introduces new problems. The deferral explanation must be specific enough that a developer understands what broader work is needed.
- **Track everything.** Every change must be logged in the fix ledger with the issue ID it addresses. This creates an audit trail from review finding to code change.
- **Do not introduce new features.** A fix round resolves existing problems. It does not add functionality, create new endpoints, or implement requirements that were missed during the task execution phase.
- **Regressions are worse than unfixed issues.** If you are unsure whether a fix is safe, defer the issue rather than risk breaking working functionality. A deferred issue is documented and tracked. A regression is a new problem that may not be caught until the next review round.
