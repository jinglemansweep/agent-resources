---
description: Break a reviewed plan into actionable tasks with checkboxes
model: deepseek/deepseek-v4-pro
---

You are breaking a finalized plan into actionable tasks. Follow these
steps in order:

1. Determine the plan to taskify:

   - If `$ARGUMENTS` is provided, use it as the plan directory path
     (e.g. `docs/plans/20260517-1430-add-user-auth`).

   - If `$ARGUMENTS` is empty, list all directories under
     `docs/plans/` sorted by most recent first. Present them to the
     user and ask them to select one. If no plans exist, inform the
     user and stop.

2. Read the `plan.md` file from the selected plan directory.

3. Perform a final review of the plan for any unresolved or open
   issues:

   a. Check for any remaining "Open Questions" section with unanswered
      items.

   b. Check the "Review" section (if present) for any "Remaining
      Action Items" that are still unresolved.

   c. Check for any TODO markers, FIXME comments, or placeholder text
      (e.g. "TBD", "TODO", "???") within the plan body.

   d. Review the current codebase to verify the plan's assumptions are
      still valid — check for conflicting recent changes
      (`git log --oneline -10`).

   - If unresolved issues are found, present each one to the user with
     clear context and ask for a resolution before proceeding. Update
     `plan.md` with the resolutions and remove resolved items.

   - If no issues are found, inform the user and proceed to step 4.

4. Generate a `tasks.md` file in the same plan directory
   (e.g. `docs/plans/20260517-1430-add-user-auth/tasks.md`).

   Break the plan into detailed, actionable tasks organized into
   logical groups of work. Use nested markdown checkboxes for progress
   tracking. Follow this structure:

   # Tasks: <Plan Title>

   > Generated from `plan.md` on <YYYY-MM-DD>

   ## <Group 1 Name>

   - [ ] <Task 1.1>
     - [ ] <Subtask 1.1.1>
     - [ ] <Subtask 1.1.2>
   - [ ] <Task 1.2>
     - [ ] <Subtask 1.2.1>

   ## <Group 2 Name>

   - [ ] <Task 2.1>
     - [ ] <Subtask 2.1.1>
   - [ ] <Task 2.2>

   Guidelines for task breakdown:

   - Each top-level group should represent a logical area of work
     (e.g. "Database Schema", "API Endpoints", "Frontend Components",
     "Testing", "Documentation").
   - Each task should be a concrete, completable unit of work — avoid
     vague tasks like "Implement feature". Prefer specific tasks like
     "Create User model with name, email, and hashed_password fields".
   - Use subtasks (nested checkboxes) to break down tasks that involve
     multiple steps.
   - Order groups and tasks to reflect a sensible implementation
     sequence — foundational work first, dependent work after.
   - Include a final "Verification" group with tasks for linting,
     type-checking, testing, and manual verification.
   - Do not pre-check any boxes — all tasks start unchecked.

5. Ensure `tasks.md` passes markdownlint (80-char line limit, no
   trailing whitespace, ends with a newline).
