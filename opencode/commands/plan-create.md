---
description: Create a timestamped PRD-style plan from a high-level summary
model: zai-coding-plan/glm-5.1
---

You are creating a PRD-style plan document. Follow these steps in order:

1. Read `$ARGUMENTS` as the high-level summary/outline for the plan.

2. Derive a short kebab-case slug (2-4 words) from the summary to
   append to the directory name.

3. Create the `docs/plans/` directory if it does not already exist:
   `mkdir -p docs/plans`

4. Create a timestamped directory under `docs/plans/` using the format
   `YYYYMMDD-HHMM-<slug>`. Get the current timestamp with
   `date +%Y%m%d-%H%M` and construct the full path. For example:
   `docs/plans/20260517-1430-add-user-auth`

5. Research context for the plan:

   a. Review the current codebase — examine directory structure, key
   files, and architecture.

   b. Review recent git history (`git log --oneline -20`) to
   understand current development activity and direction.

   c. Review any existing plans in `docs/plans/*/plan.md` to
   understand prior decisions and avoid duplicating effort. If
   related plans exist, note them as references.

6. Create `plan.md` inside the timestamped directory with the following
   PRD-style structure. Fill in each section based on the summary in
   `$ARGUMENTS` and the research from step 5.

   # <Title derived from summary>

   ## Summary

   <1-2 paragraph overview of the plan>

   ## Background & Motivation

   <Why this plan is needed. Reference current codebase state and any
   relevant git history or prior plans.>

   ## Goals
   - <Goal 1>
   - <Goal 2>

   ## Non-Goals
   - <Explicitly out of scope>

   ## Requirements

   ### Functional Requirements
   - <Requirement 1>

   ### Technical Requirements
   - <Requirement 1>

   ## Implementation Plan

   ### Phase 1: <Name>
   - <Step>

   ### Phase 2: <Name>
   - <Step>

   ## Open Questions
   - <Question 1>

   ## References
   - <Related docs/plans/\*/plan.md if any exist>
   - <Relevant git commits or issues>

7. Ensure `plan.md` passes markdownlint (80-char line limit, no
   trailing whitespace, ends with a newline).
