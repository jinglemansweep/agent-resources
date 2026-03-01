# Agent Workflow Orchestration System

## Overview

This document defines a multi-stage AI agent workflow for automated software development. The system takes an initial prompt or brief and produces a complete, reviewed, and validated codebase through a pipeline of specialised skills.

## Architecture

```
Prompt/Brief
  │
  ▼
┌─────────────┐
│  New Phase   │  Create datestamped phase directory in .plans/
└─────┬───────┘
      ▼
┌─────────────┐
│    Plan      │  Generate PRD from prompt
└─────┬───────┘
      ▼
┌─────────────┐
│ PRD Review   │  Self-critique, completeness check, human gate (optional)
└─────┬───────┘
      ▼
┌─────────────┐
│  Task        │  Convert PRD to structured task list with dependencies
│  Breakdown   │
└─────┬───────┘
      ▼
┌─────────────┐
│ Task Review  │  Validate scope, ordering, dependency DAG
└─────┬───────┘
      ▼
┌─────────────────────────────────────────┐
│           Execute Loop                   │
│  for each task (in dependency order):    │
│    1. Select role skill                  │
│    2. Implement task                     │
│    3. Validate (lint, test, type check)  │
└─────┬───────────────────────────────────┘
      ▼
┌─────────────────────────────────────────┐
│         Review & Fix Loop                │
│  1. Code Review (full codebase)          │
│  2. If CRITICAL/MAJOR issues → Fix       │
│  3. Re-validate affected files           │
│  4. Re-review changed files only         │
│  5. Repeat (max 3 rounds)                │
└─────┬───────────────────────────────────┘
      ▼
┌─────────────┐
│   Summary    │  Final report, known issues, decisions log
└─────────────┘
```

---

## Workspace

All intermediate artifacts are stored in a `.plans/` directory at the project root. Each workflow run (phase) gets its own datestamped directory, allowing multiple runs to coexist as a full history.

### Phase Directory Structure

Phases are stored under `.plans/YYYY/MM/DD/II-DESCRIPTION` where `II` is a zero-padded auto-incrementing number within that day.

```
project-root/
├── .plans/
│   ├── 2026/
│   │   └── 03/
│   │       └── 01/
│   │           ├── 01-initial-api-scaffolding/
│   │           │   ├── prompt.md
│   │           │   ├── prd.md
│   │           │   ├── prd-review.md
│   │           │   ├── tasks.yaml
│   │           │   ├── task-review.md
│   │           │   ├── state.yaml
│   │           │   ├── fix-ledger.yaml
│   │           │   ├── logs/
│   │           │   │   ├── task-001.md
│   │           │   │   ├── task-002.md
│   │           │   │   └── ...
│   │           │   ├── reviews/
│   │           │   │   ├── round-1.yaml
│   │           │   │   ├── round-2.yaml
│   │           │   │   └── ...
│   │           │   └── summary.md
│   │           └── 02-add-auth-middleware/
│   │               └── ...
│   └── ...
├── src/
├── tests/
├── Dockerfile
└── ...
```

### Conventions

- **Phase path resolution:** Every skill (except New Phase) accepts an optional phase path argument. If provided, use it directly. If omitted, list the 5 most recent phase directories (sorted by date and increment) and prompt the user to select one. This pattern is consistent across all skills.
- **Skills write to the phase directory** for all planning, review, and tracking artifacts
- **Agents write to the project root** for actual implementation files (`src/`, `tests/`, configs, etc.)
- **The orchestrator owns `state.yaml`** — this is the single source of truth for pipeline progress, allowing resumption if interrupted
- **Nothing in the phase directory is implementation code** — it's purely metadata, plans, and logs
- **`.plans/` should be gitignored** unless you want to version your planning artifacts alongside the code
- **Skills are re-runnable** — Plan, PRD Review, Task Breakdown, and Task Review can be invoked multiple times against the same phase, overwriting the previous artifact each time

### `state.yaml` Schema

```yaml
status: "in_progress"              # pending | in_progress | review | complete | failed
current_phase: "execute"           # new_phase | plan | prd_review | task_breakdown | task_review | execute | code_review | fix | summary
branch: "feat/initial-api-scaffolding"
phase_path: ".plans/2026/03/01/01-initial-api-scaffolding"
current_task: "TASK-003"
tasks:
  TASK-001: { status: "complete", agent: "python", retries: 0 }
  TASK-002: { status: "complete", agent: "node", retries: 0 }
  TASK-003: { status: "in_progress", agent: "python", retries: 0 }
  TASK-004: { status: "pending", agent: "devops", retries: 0 }
fix_round: 0
started_at: "2025-03-01T10:00:00Z"
updated_at: "2025-03-01T10:34:12Z"
```

This allows the orchestrator to resume from the last known state if a session is interrupted, rather than restarting the entire pipeline.

---

## Skills

### 1. New Phase

**Purpose:** Initialise a new phase directory for a workflow run, establishing the workspace before any other skill executes.

**Input:** A short description of the phase (e.g. "initial api scaffolding", "add auth middleware").

**Output:** A new directory at `.plans/YYYY/MM/DD/II-DESCRIPTION/` with the base artifact structure created.

**Directory naming rules:**

- `YYYY/MM/DD` — current date
- `II` — zero-padded auto-increment starting at `01`, based on existing directories for that day
- `DESCRIPTION` — the provided description, lowercased and hyphenated (spaces and special characters replaced with hyphens, consecutive hyphens collapsed)

**Procedure:**

1. **Git branch check:**
   - Detect the current branch name
   - If on `main` or `master`, prompt the user to create a new branch before proceeding
   - Suggest a branch name based on the phase description using conventional prefixes:
     - `feat/` — new functionality (e.g. `feat/api-scaffolding`)
     - `fix/` — bug fixes (e.g. `fix/auth-token-expiry`)
     - `chore/` — maintenance, config, CI (e.g. `chore/update-dependencies`)
     - `refactor/` — restructuring without behaviour change (e.g. `refactor/extract-service-layer`)
     - `docs/` — documentation only (e.g. `docs/api-reference`)
     - `test/` — test additions or fixes (e.g. `test/auth-integration`)
   - Present the suggested branch name and ask the user to confirm, edit, or skip
   - If confirmed, create and checkout the new branch
   - If the user explicitly chooses to skip, proceed on the current branch but log a warning in `state.yaml`
   - **Do not proceed silently on main/master** — always prompt
2. Get the current date and form the day path: `.plans/YYYY/MM/DD/`
3. List existing directories in the day path (if any)
4. Determine the next increment number (e.g. if `01-*` and `02-*` exist, next is `03`)
5. Sanitise the description: lowercase, replace spaces/special chars with hyphens, collapse multiples, trim trailing hyphens
6. Create the phase directory: `.plans/YYYY/MM/DD/II-DESCRIPTION/`
7. Create the subdirectory structure:
   ```
   .plans/YYYY/MM/DD/II-DESCRIPTION/
   ├── logs/
   └── reviews/
   ```
8. Create `prompt.md` with a placeholder template:
   ```markdown
   # Project Brief

   ## Overview
   <!-- What are you building? One or two sentences. -->

   ## Goals
   <!-- What should this achieve? What problem does it solve? -->

   ## Requirements
   <!-- Key features and functionality. Be specific. -->

   ## Constraints
   <!-- Tech stack, timeline, compatibility, budget, etc. -->

   ## Out of Scope
   <!-- What this phase is NOT doing. -->

   ## References
   <!-- Links, docs, existing code, inspiration. -->
   ```
9. Initialise `state.yaml` with status `pending`, the phase path, and the active branch name
10. Inform the user to edit `prompt.md` with their brief, then run `/plan <phase-path>` to continue

**Example:**

```
> /new-phase initial api scaffolding

⚠ You are on branch 'main'. It's recommended to work on a feature branch.
Suggested branch: feat/initial-api-scaffolding
[Create branch] [Edit name] [Skip]

> Create branch

Switched to new branch 'feat/initial-api-scaffolding'
Created: .plans/2026/03/01/01-initial-api-scaffolding/
```

```
> /new-phase fix auth token expiry

⚠ You are on branch 'main'. It's recommended to work on a feature branch.
Suggested branch: fix/auth-token-expiry
[Create branch] [Edit name] [Skip]

> Edit name → fix/auth-token-handling

Switched to new branch 'fix/auth-token-handling'
Created: .plans/2026/03/01/02-fix-auth-token-expiry/
```

```
> /new-phase add rate limiting

Already on branch 'feat/initial-api-scaffolding' — proceeding.
Created: .plans/2026/03/01/03-add-rate-limiting/
```

**Instructions:**

- This skill must run before all other skills in the pipeline
- The orchestrator uses the created phase path as the working directory for all subsequent artifact writes
- If the `.plans/` directory doesn't exist yet, create it

---

### 2. Plan

**Purpose:** Generate a Product Requirements Document (PRD) from an initial prompt, brief, or project directory.

**Input:** A phase path (e.g. `.plans/2026/03/01/01-initial-api-scaffolding`). If not provided, present the user with a list of recent phase directories to choose from. Reads the brief from `prompt.md` within the phase directory.

**Output:** A structured PRD written to `prd.md` in the phase directory, containing:

- Project overview and goals
- Functional requirements
- Non-functional requirements (performance, security, accessibility)
- Technical constraints and assumptions
- Scope boundaries (in-scope / out-of-scope)
- Acceptance criteria for each requirement
- Suggested tech stack (if not specified)

**Instructions:**

- Read all input material thoroughly before generating
- Ask clarifying questions only if critical information is missing and no reasonable default exists
- Prefer concrete, testable requirements over vague statements
- Each requirement must have at least one acceptance criterion

---

### 3. PRD Review

**Purpose:** Critically evaluate the PRD for completeness, consistency, and feasibility before any implementation begins.

**Input:** A phase path. If not provided, prompt the user to select from recent phases. Reads `prd.md` from the phase directory.

**Output:** A review report written to `prd-review.md` in the phase directory, containing:

- Coverage assessment: does the PRD address all points from the original prompt?
- Contradiction detection: are any requirements in conflict?
- Ambiguity flags: requirements that are too vague to implement
- Missing edge cases or error scenarios
- Feasibility concerns given stated constraints
- A verdict: PASS, REVISE (with specific feedback), or ESCALATE (needs human input)

**Instructions:**

- Compare the PRD against the original prompt line by line
- For each requirement, ask: "Could a developer implement this without further questions?"
- If the verdict is REVISE, provide specific, actionable feedback — not vague suggestions
- If the verdict is PASS, proceed automatically to Task Breakdown
- If the verdict is ESCALATE, halt the pipeline and present concerns to the user

**Optional:** Human-in-the-loop gate. If enabled, present the PRD to the user for approval before proceeding regardless of the review verdict.

---

### 4. Task Breakdown

**Purpose:** Convert the approved PRD into an ordered, structured task list suitable for execution.

**Input:** A phase path. If not provided, prompt the user to select from recent phases. Reads the approved `prd.md` from the phase directory.

**Output:** A task list written to `tasks.yaml` in the phase directory, where each task contains:

```yaml
- id: TASK-001
  title: "Short descriptive title"
  description: "What needs to be done and why"
  requirements: ["REQ-001", "REQ-003"]  # PRD requirements addressed
  dependencies: []                       # Task IDs that must complete first
  suggested_role: "backend"              # Recommended role skill
  acceptance_criteria:
    - "Criterion 1"
    - "Criterion 2"
  estimated_complexity: "small | medium | large"
  files_affected:
    - "src/api/routes.py"
    - "tests/test_routes.py"
```

**Instructions:**

- Tasks should be atomic — one clear unit of work each
- Order tasks respecting dependencies (topological sort)
- Include test-writing as explicit tasks, not afterthoughts
- Include infrastructure tasks (Dockerfile, CI config, etc.) where relevant
- Group related tasks but keep them independently executable
- Every PRD requirement must be covered by at least one task

---

### 5. Task Review

**Purpose:** Validate the task list structure, ordering, and completeness before execution.

**Input:** A phase path. If not provided, prompt the user to select from recent phases. Reads `tasks.yaml` and `prd.md` from the phase directory.

**Output:** A review report written to `task-review.md` in the phase directory, containing:

- Dependency validation: is the DAG valid? Are there circular dependencies?
- Ordering check: can tasks be executed in the proposed order without blockers?
- Coverage check: does every PRD requirement map to at least one task?
- Scope check: are tasks appropriately sized? Flag any that are too large or too vague
- A verdict: PASS or REVISE (with specific issues)

**Instructions:**

- Build the dependency graph and verify it is a valid DAG
- Simulate execution order and flag any task that references files or interfaces not yet created by prior tasks
- If REVISE, return specific task IDs and what needs to change

---

### 6. Execute (Orchestrator)

**Purpose:** Iterate through the task list in dependency order, select the appropriate role skill for each task, and manage execution state.

**Input:** A phase path. If not provided, prompt the user to select from recent phases. Reads `tasks.yaml` and `prd.md` from the phase directory. Writes per-task logs to `logs/` and updates `state.yaml` throughout execution.

**Output:** Implemented files and a per-task execution log.

**Instructions:**

- Process tasks in dependency order; parallelise independent tasks where possible
- For each task:
  1. Select the most appropriate role skill based on `suggested_role` and task content
  2. Provide the role skill with: task definition, acceptance criteria, relevant existing files, and PRD context
  3. Receive implemented files
  4. Run the Validate skill on output files
  5. If validation fails, allow the role skill one retry with the error output
  6. Log the result (success, files created/modified, issues)
- Maintain a global state of: completed tasks, generated files, and the dependency graph
- If a task fails after retry, log it as blocked and continue with independent tasks

---

### 7. Role Agents (External)

Role agents are **existing, standalone agents** maintained outside the scope of this workflow. They are general-purpose language and runtime specialists (e.g. Python, Node, Go, DevOps) that can be invoked by the orchestrator but are not owned by it.

This separation is intentional:

- Role agents are reusable across any workflow, not just this pipeline
- They can be updated, versioned, and tested independently
- The orchestrator doesn't need to know their internals — only how to delegate to them

**Agent delegation:** The orchestrator selects and invokes the appropriate agent for each task based on the `suggested_role` field and the task's language/runtime requirements.

**Example agents (maintained separately):**

- `python` — Python development, FastAPI, Django, data processing
- `node` — Node.js/TypeScript, React, Express, frontend tooling
- `devops` — Dockerfiles, CI/CD, infrastructure configs, deployment
- `database` — Schema design, migrations, query optimisation
- ...any other agents you maintain

**Context passed to agents:** When the orchestrator delegates a task, it provides:

- The task definition (title, description, acceptance criteria)
- Relevant PRD context for the task's requirements
- A list of existing files the task depends on or modifies
- Any constraints from the configuration

**Context expected back from agents:**

- Files created or modified
- A brief summary of what was done and any decisions made
- Any blockers or concerns encountered

**Instructions for the orchestrator when delegating:**

- Match tasks to agents by language/runtime, not by arbitrary role labels
- If a task spans multiple domains (e.g. backend + database), prefer the primary domain and note the secondary in context
- Do not dictate implementation details to agents — provide the what, not the how
- If no suitable agent exists for a task, flag it and attempt with the closest match

---

### 8. Validate

**Purpose:** Run automated checks on task output immediately after implementation.

**Input:** Files created or modified by the current task.

**Output:** Validation report (PASS or FAIL with details).

**Checks to run:**

- Syntax validation / linting (language-appropriate)
- Type checking (if applicable)
- Unit tests (run existing + any new tests from this task)
- Import/dependency resolution (do all imports resolve?)
- File structure (are files in the expected locations?)

**Instructions:**

- Run only checks relevant to the file types involved
- Report errors with file, line number, and description
- A single test failure is a FAIL
- Do not attempt to fix issues — report them back to the orchestrator

---

### 9. Code Review

**Purpose:** Holistic review of the codebase after all tasks are executed (or after a fix round, scoped to changed files).

**Input:** The full codebase (first run) or changed files only (subsequent fix rounds). Reads task context from the phase directory. Writes issues to `reviews/round-N.yaml` in the phase directory.

**Output:** A list of issues, each containing:

```yaml
- id: ISSUE-001
  severity: "CRITICAL | MAJOR | MINOR"
  category: "integration | architecture | security | duplication | error-handling | style"
  file: "src/api/routes.py"
  line: 42
  description: "What the issue is"
  suggestion: "How to fix it"
  related_tasks: ["TASK-003", "TASK-007"]
```

**Severity definitions:**

- **CRITICAL:** Broken functionality, missing integration between components, security vulnerabilities, data loss risk
- **MAJOR:** Architectural inconsistency, significant duplication, missing error handling for likely failure modes, broken contracts between modules
- **MINOR:** Naming inconsistencies, style issues, missing documentation, minor code smells

**Instructions:**

- Focus on integration points between components — this is where task-by-task execution most commonly produces gaps
- Check that all API contracts match between producers and consumers
- Verify error propagation across module boundaries
- Flag dead code or unused imports introduced during implementation
- Do not re-review files that haven't changed in fix rounds

---

### 10. Fix

**Purpose:** Apply corrections based on code review feedback.

**Input:** A list of CRITICAL and MAJOR issues from the latest review round in the phase directory, the affected files, and the original task context.

**Output:** Corrected files and a fix report listing what was changed and why.

**Instructions:**

- Address only the issues provided — do not refactor unrelated code
- Maintain existing code style and patterns
- If a fix requires changes to multiple files, make all related changes together
- If an issue cannot be resolved without significant architectural changes, flag it as DEFERRED with an explanation rather than attempting a risky fix
- Log every change made with the issue ID it addresses

---

### 11. Summary

**Purpose:** Generate a final report of the entire workflow run.

**Input:** All logs, review reports, and the fix ledger from the phase directory.

**Output:** A markdown report written to `summary.md` in the phase directory, containing:

- Project overview (from PRD)
- Tasks completed and their status
- Files created and modified
- Review rounds: issues found, fixed, and remaining
- Known issues and deferred items
- Decisions made during execution (tech choices, trade-offs)
- Suggested next steps or follow-up tasks

---

## Review & Fix Loop Protocol

After the Execute phase completes all tasks, the orchestrator enters the review and fix loop.

### Rules

1. Run Code Review against the full codebase
2. Collect all issues and categorise by severity
3. MINOR issues are logged in the summary but **never trigger a fix round**
4. If CRITICAL or MAJOR issues exist, enter the fix loop
5. Pass issues to the Fix skill with: issue description, affected files, original task context
6. After fixes, run Validate on affected files only
7. Run Code Review on changed files only
8. Repeat from step 4

### Exit Conditions

- **Success:** A review round produces zero CRITICAL or MAJOR issues → exit loop, proceed to Summary
- **Iteration limit:** Maximum **3 fix rounds**. If issues remain after 3 rounds, log all remaining issues as known issues and proceed to Summary
- **Regression detected:** If any fix round introduces more new CRITICAL/MAJOR issues than it resolves, **stop immediately**. Log the regression and proceed to Summary. The fixes are making things worse.

### Fix Ledger

The orchestrator maintains a ledger across fix rounds:

```yaml
fix_rounds:
  - round: 1
    issues_input: 5
    issues_fixed: 4
    issues_remaining: 1
    regressions_introduced: 0
  - round: 2
    issues_input: 1
    issues_fixed: 1
    issues_remaining: 0
    regressions_introduced: 0
    exit_reason: "All issues resolved"
```

---

## Configuration

Configuration lives directly in the orchestrator's `SKILL.md` as plain text instructions rather than in a separate file. This is intentional — skills and agents behave most reliably when their instructions are in the prompt itself, not parsed from an external config file at runtime.

Edit these values in `skills/execute/SKILL.md` to adjust behaviour:

```markdown
## Orchestrator Configuration

- Pause for human approval after PRD Review: No
- Pause for human approval after Task Review: No
- Maximum fix rounds: 3
- Maximum retries per task on validation failure: 1
- Include MINOR issues in fix loop: No

### Available Agents

The following agents are available for task delegation. Match tasks to agents
by language, runtime, or domain:

- python — Python, FastAPI, Django, data processing
- node — Node.js, TypeScript, React, Express
- devops — Dockerfiles, CI/CD, infrastructure, deployment
- database — Schema design, migrations, queries

### Validation Checks

Run the following checks after each task:
- Linting: Yes
- Type checking: Yes
- Run tests: Yes

### Summary Output

- Format: Markdown
- Include fix ledger: Yes
- Include decision log: Yes
```

This approach keeps everything in one place, is easy to read and edit, and avoids the agent needing to locate, read, and correctly interpret a separate YAML file at runtime.

---

## Usage

This workflow is designed for use with Claude Code custom skills and agents. Each skill above corresponds to a skill prompt file that Claude Code can invoke.

### Directory Structure

```
skills/
├── new-phase/
│   └── SKILL.md
├── plan/
│   └── SKILL.md
├── prd-review/
│   └── SKILL.md
├── task-breakdown/
│   └── SKILL.md
├── task-review/
│   └── SKILL.md
├── execute/
│   └── SKILL.md          # Orchestrator — chains skills and delegates to agents
├── validate/
│   └── SKILL.md
├── code-review/
│   └── SKILL.md
├── fix/
│   └── SKILL.md
└── summary/
    └── SKILL.md

# Role agents are maintained separately, e.g.:
agents/
├── python/
│   └── AGENT.md
├── node/
│   └── AGENT.md
├── devops/
│   └── AGENT.md
└── ...
```

### Invocation

The workflow is driven by invoking individual skills with a **phase path** argument. The typical workflow is:

**Step 1: Create a new phase**
```
> /new-phase initial api scaffolding
Created: .plans/2026/03/01/01-initial-api-scaffolding/
Edit your brief in: .plans/2026/03/01/01-initial-api-scaffolding/prompt.md
```

**Step 2: Edit `prompt.md`** with your project brief.

**Step 3: Run skills against the phase**
```
> /plan .plans/2026/03/01/01-initial-api-scaffolding
> /prd-review .plans/2026/03/01/01-initial-api-scaffolding
> /task-breakdown .plans/2026/03/01/01-initial-api-scaffolding
> /task-review .plans/2026/03/01/01-initial-api-scaffolding
> /execute .plans/2026/03/01/01-initial-api-scaffolding
```

**Phase path is optional.** If omitted, the skill presents the user with a list of recent phase directories to choose from:

```
> /plan

Recent phases:
  1. .plans/2026/03/01/02-add-auth-middleware
  2. .plans/2026/03/01/01-initial-api-scaffolding
  3. .plans/2026/02/28/01-database-schema-redesign
Which phase? [1]
```

**Skills can be re-run.** The Plan, PRD Review, Task Breakdown, and Task Review skills can all be invoked multiple times against the same phase. Each run overwrites the previous artifact (e.g. re-running `/plan` regenerates `prd.md`). This supports an iterative workflow where you refine the prompt, re-plan, re-review, and only execute when satisfied.

The orchestrator (Execute skill) chains the Review & Fix loop and Summary automatically once execution begins.
