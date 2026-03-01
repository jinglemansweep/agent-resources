# Task List

> Source: `.plans/20260301/01-agent-skill-refactor/plan.md`

## Phase Management

### Rewrite `jms-phase-new`

- [x] **Rewrite `plugins/jinglemansweep/skills/jms-phase-new/SKILL.md`** — Replace the existing skill with the new specification. The rewritten skill must:
  - Change the directory format from `YYYYMMDD/NN-slug` to `YYYY/MM/DD/NN-slug` (nested year/month/day directories)
  - Change branch naming from `plan/<slug>` to conventional prefixes (`feat/`, `fix/`, `chore/`, `refactor/`, `docs/`, `test/`) derived from the phase description. The skill should suggest a prefix based on keywords in the description and prompt the user to confirm, edit, or skip
  - Create `prompt.md` with a structured template containing sections: Overview, Goals, Requirements, Constraints, Out of Scope, References (each with HTML comment placeholders)
  - Create `logs/` and `reviews/` subdirectories inside the phase directory
  - Initialize `state.yaml` with `status: pending`, the phase path, and the active branch name
  - Retain the existing behaviour of detecting if on `main`/`master` and prompting to create a branch, but use the new conventional prefix format
  - Include the example interactions from the prompt (Section 1: New Phase) showing the branch suggestion flow
  - Verify by reading the completed SKILL.md and confirming it covers: directory creation, branch handling, prompt.md template, state.yaml init, logs/reviews subdirs

## Plan Generation

### Rewrite `jms-plan`

- [x] **Rewrite `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — Replace the existing skill that generates three files (`research.md`, `plan.md`, `issues.md`) with a new version that generates a single `prd.md`. The rewritten skill must:
  - Accept a phase path argument (optional — if omitted, list the 5 most recent phase directories sorted by date and increment, prompt the user to select one)
  - Read `prompt.md` from the phase directory
  - Generate `prd.md` containing: project overview and goals, functional requirements (each with an ID like `REQ-001`), non-functional requirements (performance, security, accessibility), technical constraints and assumptions, scope boundaries (in-scope / out-of-scope), acceptance criteria for each requirement, and suggested tech stack
  - Each requirement must have at least one acceptance criterion
  - Remove all references to `research.md`, `plan.md`, and `issues.md` generation — these no longer exist
  - The skill should ask clarifying questions only if critical information is missing and no reasonable default exists
  - Verify by reading the completed SKILL.md and confirming it produces `prd.md` with structured requirements

## PRD Review

### Create `jms-prd-review`

- [ ] **Create `plugins/jinglemansweep/skills/jms-prd-review/SKILL.md`** — New skill that critically evaluates the PRD before implementation. The skill must:
  - Accept a phase path argument (optional — if omitted, list 5 most recent phases for selection)
  - Read `prd.md` and `prompt.md` from the phase directory
  - Generate `prd-review.md` in the phase directory containing: coverage assessment (does the PRD address all points from the original prompt?), contradiction detection, ambiguity flags, missing edge cases or error scenarios, feasibility concerns, and a verdict
  - The verdict must be one of: `PASS` (proceed to Task Breakdown), `REVISE` (with specific, actionable feedback — not vague suggestions), or `ESCALATE` (halt pipeline for human input)
  - Compare the PRD against the original prompt line by line
  - For each requirement, evaluate: "Could a developer implement this without further questions?"
  - Include an optional human-in-the-loop gate: if enabled, present the PRD to the user for approval regardless of the review verdict
  - Verify by reading the completed SKILL.md and confirming it covers all review criteria and verdict handling

## Task Breakdown

### Create `jms-task-breakdown` (replaces `jms-taskify`)

- [ ] **Create `plugins/jinglemansweep/skills/jms-task-breakdown/SKILL.md`** — New skill that replaces `jms-taskify`. Converts the approved PRD into a structured YAML task list. The skill must:
  - Accept a phase path argument (optional — if omitted, list 5 most recent phases for selection)
  - Read the approved `prd.md` from the phase directory
  - Generate `tasks.yaml` (not `tasks.md`) in the phase directory. Each task entry must have the following YAML fields:
    ```yaml
    - id: TASK-NNN          # Zero-padded three-digit ID
      title: "Short descriptive title"
      description: "What needs to be done and why"
      requirements: ["REQ-001"]  # PRD requirement IDs addressed
      dependencies: []           # Task IDs that must complete first
      suggested_role: "python"   # Maps to existing role agents
      acceptance_criteria:
        - "Criterion 1"
      estimated_complexity: "small | medium | large"
      files_affected:
        - "path/to/file"
    ```
  - Order tasks by topological sort of their dependency graph
  - Ensure every PRD requirement is covered by at least one task
  - Include test-writing as explicit tasks
  - Include infrastructure tasks (Dockerfile, CI config) where relevant
  - Tasks should be atomic — one clear unit of work each
  - The `suggested_role` field must map to existing role agents: `python`, `node`/`nodejs`, `devops`, `frontend`, `general`, `docs`
  - Verify by reading the completed SKILL.md and confirming it produces valid YAML with all required fields

## Task Review

### Create `jms-task-review`

- [ ] **Create `plugins/jinglemansweep/skills/jms-task-review/SKILL.md`** — New skill that validates the task list structure, ordering, and completeness. The skill must:
  - Accept a phase path argument (optional — if omitted, list 5 most recent phases for selection)
  - Read `tasks.yaml` and `prd.md` from the phase directory
  - Generate `task-review.md` in the phase directory containing:
    - Dependency validation: build the dependency graph and verify it is a valid DAG with no circular dependencies
    - Ordering check: simulate execution order and flag any task that references files or interfaces not yet created by prior tasks
    - Coverage check: verify every PRD requirement (`REQ-NNN`) maps to at least one task
    - Scope check: flag tasks that are too large or too vague
    - A verdict: `PASS` or `REVISE` (with specific task IDs and what needs to change)
  - Verify by reading the completed SKILL.md and confirming it covers all validation criteria

## Execution Sub-Skills

### Create `jms-validate`

- [ ] **Create `plugins/jinglemansweep/skills/jms-validate/SKILL.md`** — New skill for post-task automated validation. This is a standalone, user-invocable skill primarily called by the Execute orchestrator. The skill must:
  - Accept as input the files created or modified by the current task (file paths provided by the caller)
  - Run only checks relevant to the file types involved:
    - Syntax validation / linting (language-appropriate)
    - Type checking (if applicable, e.g. `mypy` for Python, `tsc --noEmit` for TypeScript)
    - Unit tests (run existing + any new tests from this task)
    - Import/dependency resolution (do all imports resolve?)
    - File structure verification (are files in expected locations?)
  - Output a validation report with verdict `PASS` or `FAIL`
  - On `FAIL`, include file path, line number, and error description for each issue
  - The skill must NOT attempt to fix issues — only report them
  - Verify by reading the completed SKILL.md

### Create `jms-code-review`

- [ ] **Create `plugins/jinglemansweep/skills/jms-code-review/SKILL.md`** — New skill for holistic code review. This is a standalone, user-invocable skill primarily called by the Execute orchestrator. The skill must:
  - Accept a phase path and an optional scope: `full` (first run — review entire codebase) or `changed` (fix rounds — review only changed files)
  - Read task context from the phase directory (`tasks.yaml`, `prd.md`)
  - Write issues to `reviews/round-N.yaml` in the phase directory (N determined by counting existing review files + 1)
  - Each issue in the YAML must have fields: `id` (ISSUE-NNN), `severity` (CRITICAL / MAJOR / MINOR), `category` (integration / architecture / security / duplication / error-handling / style), `file`, `line`, `description`, `suggestion`, `related_tasks` (list of TASK-NNN IDs)
  - Severity definitions: CRITICAL = broken functionality, missing integration, security vulnerabilities, data loss risk. MAJOR = architectural inconsistency, significant duplication, missing error handling, broken contracts. MINOR = naming, style, missing docs, minor code smells
  - Focus on integration points between components
  - Check API contracts match between producers and consumers
  - Verify error propagation across module boundaries
  - Flag dead code or unused imports
  - Verify by reading the completed SKILL.md

### Create `jms-fix`

- [ ] **Create `plugins/jinglemansweep/skills/jms-fix/SKILL.md`** — New skill for applying corrections based on code review feedback. This is a standalone, user-invocable skill primarily called by the Execute orchestrator. The skill must:
  - Accept as input: CRITICAL and MAJOR issues from the latest review round (issue IDs, descriptions, affected files), and original task context from the phase directory
  - Address only the issues provided — no unrelated refactoring
  - Maintain existing code style and patterns
  - If a fix requires changes to multiple files, make all related changes together
  - If an issue cannot be resolved without significant architectural changes, flag it as `DEFERRED` with an explanation
  - Log every change made with the issue ID it addresses
  - Output a fix report listing: issue ID addressed, files changed, description of the fix
  - Verify by reading the completed SKILL.md

### Create `jms-summary`

- [ ] **Create `plugins/jinglemansweep/skills/jms-summary/SKILL.md`** — New skill for generating a final workflow summary report. This is a standalone, user-invocable skill primarily called by the Execute orchestrator at pipeline end. The skill must:
  - Accept a phase path argument (optional — if omitted, list 5 most recent phases for selection)
  - Read all logs (`logs/task-NNN.md`), review reports (`reviews/round-N.yaml`), `fix-ledger.yaml`, `tasks.yaml`, `prd.md`, and `state.yaml` from the phase directory
  - Generate `summary.md` in the phase directory containing:
    - Project overview (from PRD)
    - Tasks completed and their status
    - Files created and modified
    - Review rounds: issues found, fixed, and remaining
    - Known issues and deferred items
    - Decisions made during execution (tech choices, trade-offs)
    - Suggested next steps or follow-up tasks
  - Verify by reading the completed SKILL.md

## Execution Orchestrator

### Rewrite `jms-execute`

- [ ] **Rewrite `plugins/jinglemansweep/skills/jms-execute/SKILL.md`** — Major rewrite as a full pipeline orchestrator. This is the most complex skill. Requires: Phase Management, Task Breakdown, and all Execution Sub-Skills groups to be complete. The rewritten skill must:
  - Accept a phase path argument (optional — if omitted, list 5 most recent phases for selection)
  - Read `tasks.yaml` and `prd.md` from the phase directory
  - Read `state.yaml` on start to determine where to resume if interrupted mid-run
  - Process tasks sequentially in dependency order (parallel execution deferred to future)
  - For each task:
    1. Select the appropriate role agent based on `suggested_role` and task content (map to `jms-role-python`, `jms-role-nodejs`, `jms-role-devops`, `jms-role-frontend`, `jms-role-general`, `jms-role-docs`)
    2. Provide the role agent with: task definition, acceptance criteria, relevant existing files, PRD context
    3. Run `/jms-validate` on output files after implementation
    4. If validation fails, allow one retry with the error output
    5. Log the result to `logs/task-NNN.md` (success/failure, files created/modified, issues)
    6. Update `state.yaml` with task status, agent used, retry count
  - After all tasks complete, enter the Review & Fix Loop:
    1. Run `/jms-code-review` against the full codebase (scope: `full`)
    2. Collect all issues by severity
    3. If CRITICAL or MAJOR issues exist, run `/jms-fix` with those issues
    4. After fixes, run `/jms-validate` on affected files
    5. Run `/jms-code-review` on changed files only (scope: `changed`)
    6. Repeat (max 3 rounds)
    7. Exit conditions: zero CRITICAL/MAJOR issues (success), 3 rounds reached (log remaining as known issues), regression detected (more new issues than resolved — stop immediately)
  - Maintain `fix-ledger.yaml` tracking per-round: issues_input, issues_fixed, issues_remaining, regressions_introduced, exit_reason
  - After the review & fix loop exits, run `/jms-summary` to generate the final report
  - Update `state.yaml` throughout with: overall status, current_phase, branch, current_task, per-task status, fix_round, timestamps
  - Embed the orchestrator configuration directly in the SKILL.md (not in a separate config file):
    - Pause for human approval after PRD Review: No
    - Pause for human approval after Task Review: No
    - Maximum fix rounds: 3
    - Maximum retries per task on validation failure: 1
    - Include MINOR issues in fix loop: No
    - Available agents list with language/domain mappings
    - Validation checks to run (linting, type checking, tests)
    - Summary output format (Markdown, include fix ledger, include decision log)
  - MINOR issues are logged in the summary but never trigger a fix round
  - If a task fails after retry, log it as blocked and continue with independent tasks
  - Verify by reading the completed SKILL.md and confirming it covers: state management, task iteration, agent delegation, validation, review & fix loop, fix ledger, summary generation, embedded config, resumability

## Planner Agent

### Update `jms-planner`

- [ ] **Update `plugins/jinglemansweep/agents/jms-planner.md`** — Modify the existing planner agent to reflect the new pipeline stages. Requires: all new skills to be created. Changes:
  - Update the workflow from: init → phase → plan → hand off for review → taskify
  - To the new workflow: init → phase → plan → PRD review → task breakdown → task review → hand off for execution
  - Reference the new skill names: `/jms-prd-review`, `/jms-task-breakdown`, `/jms-task-review` (replacing `/jms-review` and `/jms-taskify`)
  - Remove any references to `jms-executor` agent — the Execute skill is the orchestrator now
  - Remove references to the old three-file output (`research.md`, `plan.md`, `issues.md`) — replace with `prd.md`
  - Remove references to `tasks.md` — replace with `tasks.yaml`
  - Update the directory format references from `YYYYMMDD/NN-slug` to `YYYY/MM/DD/NN-slug`
  - The agent still hands off to the user for interactive steps (e.g. PRD review with human gate)
  - Verify by reading the completed agent file and confirming the workflow matches the new pipeline

## Cleanup & Metadata

### Remove Deprecated Skills and Agents

- [ ] **Delete `plugins/jinglemansweep/skills/jms-taskify/SKILL.md`** — Remove the old `jms-taskify` skill directory entirely. It has been replaced by `jms-task-breakdown`. Verify the `jms-task-breakdown` skill exists before deleting.

- [ ] **Delete `plugins/jinglemansweep/skills/jms-review/SKILL.md`** — Remove the old `jms-review` skill directory entirely. It has been replaced by `jms-prd-review` and `jms-task-review`. Verify both replacement skills exist before deleting.

### Update Plugin Metadata

- [ ] **Update `plugins/jinglemansweep/plugin.json`** — Modify the skills and agents arrays to reflect the refactored pipeline. Changes:
  - Remove `jms-review` from the `skills` array
  - Remove `jms-taskify` from the `skills` array
  - Add the following to the `skills` array: `jms-prd-review`, `jms-task-breakdown`, `jms-task-review`, `jms-validate`, `jms-code-review`, `jms-fix`, `jms-summary`
  - The `agents` array stays the same (no `jms-executor` existed; all `jms-role-*` agents and `jms-planner` remain)
  - Bump the version (e.g. from `0.2.0` to `0.3.0`)
  - The final `skills` array should contain: `jms-init`, `jms-phase-new`, `jms-plan`, `jms-prd-review`, `jms-task-breakdown`, `jms-task-review`, `jms-execute`, `jms-validate`, `jms-code-review`, `jms-fix`, `jms-summary`, `jms-git-push`
  - Verify by reading `plugin.json` after editing and confirming the arrays are correct

### Update Documentation

- [ ] **Update `README.md`** — Update the project documentation to reflect the refactored skill set. Changes:
  - Update the directory tree to show the new skill directories (`jms-prd-review`, `jms-task-breakdown`, `jms-task-review`, `jms-validate`, `jms-code-review`, `jms-fix`, `jms-summary`) and the removal of `jms-taskify` and `jms-review`
  - Update the pipeline description to reflect the new stages: New Phase → Plan → PRD Review → Task Breakdown → Task Review → Execute (with Validate, Code Review, Fix, Summary sub-stages)
  - Update skill descriptions to match the new skill purposes
  - Update the phase directory format from `YYYYMMDD/NN-slug` to `YYYY/MM/DD/NN-slug`
  - Update artifact references: `prd.md` instead of `plan.md`/`research.md`/`issues.md`, `tasks.yaml` instead of `tasks.md`
  - Verify by reading the updated README and confirming it accurately reflects the new system
