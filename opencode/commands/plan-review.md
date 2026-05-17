---
description: Review a plan for issues, gaps, and conflicts
model: deepseek/deepseek-v4-pro
---

You are reviewing a PRD-style plan document. Follow these steps in
order:

1. Determine the plan to review:

   - If `$ARGUMENTS` is provided, use it as the plan directory path
     (e.g. `docs/plans/20260517-1430-add-user-auth`).

   - If `$ARGUMENTS` is empty, list all directories under
     `docs/plans/` sorted by most recent first. Present them to the
     user and ask them to select one. If no plans exist, inform the
     user and stop.

2. Read the `plan.md` file from the selected plan directory.

3. Research context for the review:

   a. Review the current codebase — examine directory structure, key
      files, and architecture. Check whether any parts of the plan
      conflict with the current codebase state.

   b. Review recent git history (`git log --oneline -20`) for changes
      that may conflict with or duplicate the plan.

   c. Read all other `docs/plans/*/plan.md` files. Check for
      overlapping goals, conflicting requirements, or dependencies
      between plans.

4. Analyze the plan for the following categories of issues:

   - **Conflicts**: Plan conflicts with current codebase, recent
     commits, or other existing plans.
   - **Gaps**: Missing requirements, incomplete technical details, or
     unspecified edge cases.
   - **Ambiguities**: Vague or unclear requirements that could lead
     to different interpretations.
   - **Risks**: Technical debt, performance concerns, or dependency
     risks not addressed in the plan.
   - **Open Questions**: Unresolved items already flagged in the
     plan's "Open Questions" section.

5. For each issue found:

   - If the issue can be resolved automatically (e.g. a factual
     correction, filling in a gap with clear codebase evidence),
     resolve it directly.

   - If the issue requires a decision, present it to the user as a
     question with clear options. Mark the recommended option with
     "(Recommended)". Include enough context for the user to make an
     informed choice.

6. After all issues are resolved, update the `plan.md` file. Add a
   `## Review` section after the existing content with the following
   structure:

   ## Review

   **Status**: Approved | Approved with Changes | Needs Revision

   **Reviewed**: <YYYY-MM-DD>

   ### Resolutions

   - <Issue>: <Resolution chosen>

   ### Remaining Action Items

   - <Any follow-up items from the review>

   Update the rest of `plan.md` to incorporate the resolved changes
   directly into the relevant sections. Remove any "Open Questions"
   that were resolved during the review.

7. Ensure the updated `plan.md` passes markdownlint (80-char line
   limit, no trailing whitespace, ends with a newline).
