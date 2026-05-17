---
description: Execute all tasks from a plan's task list sequentially
model: zai-coding-plan/glm-5.1
agent: plan-agent
---

You are executing a finalized task list. Follow these steps in order:

1. Determine the plan to execute:

   - If `$ARGUMENTS` is provided, use it as the plan directory path
     (e.g. `docs/plans/20260517-1430-add-user-auth`).

   - If `$ARGUMENTS` is empty, list all directories under
     `docs/plans/` sorted by most recent first. Present them to the
     user and ask them to select one. If no plans exist, inform the
     user and stop.

2. Read the `tasks.md` and `plan.md` files from the selected plan
   directory. These together provide the full context: `plan.md`
   contains the PRD and technical requirements; `tasks.md` contains
   the ordered checklist of work items.

3. Gather project context before starting any implementation:

   a. Check for `AGENTS.md` and `README.md` in the project root.
     Read them to learn project conventions (virtualenv setup,
     package installation, pre-commit configuration, test commands,
     linting commands, build commands, etc.).

   b. Detect the project type and prepare the environment:

     - **Python projects**: Check for a virtual environment
       (`.venv/`, `venv/`, or similar). If one exists, activate it
       before running any commands. If `requirements.txt`,
       `pyproject.toml`, or `setup.py` exists, ensure dependencies
       are installed. Check for `pre-commit` configuration
       (`.pre-commit-config.yaml`) and install hooks if needed
       (`pre-commit install`).

     - **Node.js projects**: Check for `package.json`. Run
       `npm install` (or `pnpm install` / `yarn` if lock files
       indicate a different package manager) to ensure
       dependencies are installed.

     - **Other project types**: Follow conventions found in
       AGENTS.md/README.md.

   c. Run the full quality gate suite once on the current codebase
     to establish a baseline. Run all of the following that apply:

     - Pre-commit: `pre-commit run --all-files`
     - Tests: `pytest`, `npm test`, or equivalent based on
       project type

     If there are pre-existing failures, fix them first before
     proceeding to task implementation. All quality gates must pass
     as a clean starting point. Inform the user about any
     pre-existing issues you discover and fix.

4. Implement tasks from `tasks.md` sequentially, group by group:

   For each group in `tasks.md`:

   a. Implement each task and subtask within the group. Use the
     context from `plan.md` to understand the intent behind each
     task. Implement changes carefully, following the project's
     coding conventions discovered in step 3.

   b. After completing all tasks within a group, run the full
     quality gate suite:

     - Pre-commit: `pre-commit run --all-files`
     - Tests: `pytest`, `npm test`, or equivalent

     If any quality gate fails, fix the failures before proceeding
     to the next group. Do not move on until ALL gates pass.

   c. After the group passes all quality gates, update `tasks.md`
     by marking every completed task and subtask in that group with
     `[x]` instead of `[ ]`.

5. After all groups are complete, run the final full quality gate
   suite one more time:

   - Pre-commit: `pre-commit run --all-files`
   - Tests: `pytest`, `npm test`, or equivalent

   If any failures remain, fix them. ALL quality gates must pass
   before the command is considered complete.

6. Final update of `tasks.md`: verify every checkbox is marked
   `[x]`.

7. Report a summary to the user: number of tasks completed,
   any issues encountered and how they were resolved, and the
   final status of all quality gates.
