---
name: jms-execute
description: Implement tasks from a task list with quality gates and git commits per group
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Task
---

# jms-execute

Implement tasks from a task list, grouped by section, with quality gates and commits per group.

## Usage

```
/jms-execute <plan-dir>
```

**Argument:**
- `<plan-dir>` — Path to the plan directory (e.g. `.plans/20260115/01-initial-implementation`). This directory must contain `tasks.md`.

**Directory convention:**

```
<plan-dir>/
├── prompt.md       ← original requirements (not read by this skill)
├── research.md     ← research findings (not read by this skill)
├── plan.md         ← implementation plan (not read by this skill)
├── issues.md       ← issues and risks (not read by this skill)
└── tasks.md        ← task list (input — the ONLY file this skill reads)
```

## Task Grouping

Tasks in `tasks.md` are organized under markdown headings (e.g., `## API Layer — Core Endpoints`). Each heading defines a **group** — a logical unit of work. All tasks under a heading belong to the same group. Quality gates and git commits happen once per group, not per task.

## Instructions

### Step 1: Read the Task List

Read `<plan-dir>/tasks.md`. If missing, stop and tell the user to run `jms-taskify` first.

### Step 2: Find the Next Incomplete Group

Scan `tasks.md` for the first group (heading section) that contains at least one unchecked task (`- [ ]`). This is the current group. If all tasks across all groups are checked (`- [x]`), report that all tasks are complete and stop.

### Step 3: Detect Role

Analyze the task descriptions in the current group to determine the best-fit role agent. Look for:

- **File extensions** mentioned in task text (`.py`, `.js`, `.ts`, `.jsx`, `.tsx`, `.vue`, `.css`, `.html`, `.md`, `Dockerfile`, `.yml`/`.yaml`)
- **Framework/tool keywords** (pytest, django, fastapi, npm, express, vitest, react, tailwind, docker, terraform, github actions)
- **Action verbs and context** (write docs, update README → docs; build container, add workflow → devops)

**Role selection:**

| Role Agent | Signals |
|---|---|
| `jms-role-python` | `.py`, pytest, django, fastapi, flask, pyproject.toml, pip, poetry |
| `jms-role-nodejs` | `.js`, `.ts`, npm, pnpm, express, vitest, jest, package.json, node |
| `jms-role-frontend` | `.jsx`, `.tsx`, `.vue`, `.css`, `.html`, react, tailwind, component, styled |
| `jms-role-devops` | Dockerfile, docker-compose, `.github/workflows/`, terraform, ansible, CI/CD, pipeline |
| `jms-role-docs` | `.md` files when the task is *about writing/updating documentation*, README, changelog, API docs |
| `jms-role-general` | No clear domain match, mixed concerns, or two roles closely tied |

Use `jms-role-general` if no role has a clear majority of signals, or if the group spans multiple domains.

### Step 4: Delegate to Role Agent

Spawn the detected role agent using the `Task` tool with `subagent_type` set to `general-purpose`. Provide:

- The agent name (e.g. `jms-role-python`)
- A prompt containing:
  - The full path to `tasks.md`
  - The current group heading
  - The verbatim task list for the current group (copy the unchecked tasks exactly)
  - Instruction to implement each task and mark it done (`- [x]`) in `tasks.md`

Example prompt structure:

```
You are acting as the jms-role-python agent. Follow the instructions in your agent definition.

tasks.md path: <plan-dir>/tasks.md
Group: ## <group heading>

Tasks to implement:
- [ ] Task 1 description
- [ ] Task 2 description
  - [ ] Subtask 2a

Implement each task in order and mark it done in tasks.md.
```

**Fallback:** If the Task tool fails to spawn the role agent (error, agent not found, etc.), fall back to implementing all tasks in the current group directly — same as the original behavior. Implement every unchecked task in the current group, in order. Mark each task as done (`- [x]`) in `tasks.md` as you complete it.

### Step 5: Verify Completion

Re-read `tasks.md` after the sub-agent returns. Check that all tasks in the current group are now marked done (`- [x]`).

If any tasks in the current group remain unchecked:
- Report which tasks were not completed
- Stop and ask the user how to proceed (retry, skip, or fix manually)
- Do NOT continue to quality gates with incomplete tasks

### Step 6: Quality Gates (After the Group)

After all tasks in the group are verified complete, run **all** applicable quality checks:

1. **Linting** — run the project's configured linter(s). Fix all errors and warnings.
2. **Type checking** — run type checkers if configured. Fix all errors.
3. **Tests** — run the project's test suite. Fix all failures.
4. **Build** — run the build if applicable. Fix all errors.

Detect which tools are available by checking project config files (`package.json`, `pyproject.toml`, `Makefile`, `.github/workflows/`, etc.) and use whatever is configured.

**ALL errors and warnings must be resolved before proceeding.** If a quality gate fails:
1. Fix the issue.
2. Re-run **all** quality gates from the beginning (not just the one that failed).
3. Repeat until every gate passes cleanly.

### Step 7: Git Commit (After the Group)

Create a single git commit (do NOT push) with all changes from the group. The commit message should follow the format:

```
<type>: <concise description of what was implemented>

Group: <group heading from tasks.md>
Plan: <plan-dir>
```

Where `<type>` is one of: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`.

### Step 8: Stop

**STOP.** Report to the user:
- Which group was completed
- Which role agent was used (and whether fallback was needed)
- Summary of tasks implemented
- Quality gate results (all passing)
- The git commit that was created
- How many groups remain

Then prompt the user to clear context before continuing:

> Context should be cleared before the next group. Run `/clear` then re-invoke `/jms-execute <plan-dir>` to continue.

**Do NOT proceed to the next group.** Each group runs in a fresh context to avoid accumulated context degradation.

## Guidelines

- **One group per invocation.** Never implement more than one group (heading section) per run. Implement all tasks within that group before stopping.
- **`tasks.md` is the only input.** Do not read or reference planning files. Everything needed is in the task description.
- **Zero tolerance on quality gates.** No warnings, no skipped tests, no "will fix later". Every gate must pass before the group is considered complete.
- **Do not refactor or improve code beyond the tasks.** If you notice issues in unrelated code, leave them — they may be addressed by a future task.
- **Do not skip tasks or groups.** Tasks and groups are ordered intentionally. Implement them in sequence.
- **Commit granularity = one group.** Each commit corresponds to one completed group of tasks.
