---
name: pq-review
description: Review and resolve issues in a plan directory through interactive user decisions
allowed-tools: Read, Edit, Write, Glob, AskUserQuestion
---

# pq-review

Review and resolve issues in a plan directory. Reads all plan artifacts, presents each unresolved issue to the user for a decision, then propagates those decisions into the plan and research files. Designed to be run multiple times — each run resolves open items and may surface new ones.

## Usage

```
/pq-review <plan-dir>
```

**Argument:**
- `<plan-dir>` — Path to the plan directory (e.g. `.plans/20260115/01-initial-implementation`). This directory must already contain `issues.md` and at least `plan.md`.

**Directory convention:**

```
<plan-dir>/
├── prompt.md       ← original requirements (read for context)
├── research.md     ← research findings (read + updated)
├── plan.md         ← implementation plan (read + updated)
└── issues.md       ← issues and risks (read + updated)
```

## Issue Status Convention

Items in `issues.md` use a status prefix to track resolution:

- **Unresolved:** plain bullet — `- The item text...`
- **Resolved:** prefixed with `[RESOLVED]` — `- [RESOLVED] The item text... → **Decision:** What was decided and why.`

The skill only processes unresolved items. Resolved items are left in place as a decision log.

## Instructions

### Step 1: Read All Artifacts

Read the following files from `<plan-dir>/`:

1. `issues.md` — **required**. If missing, stop and tell the user to run `pq-plan` first.
2. `plan.md` — **required**. If missing, stop and tell the user to run `pq-plan` first.
3. `research.md` — read if present.
4. `prompt.md` — read if present, for original context.

Build a complete mental model of the project from these files before proceeding.

### Step 2: Parse Unresolved Issues

Scan `issues.md` for all unresolved items — bullets that do **not** start with `[RESOLVED]`. Group them by their existing category (Open Questions, Potential Blockers, Risks, Future Considerations).

If there are no unresolved items, skip to Step 5 (cross-check).

### Step 3: Present Issues to the User

For each unresolved issue, present it to the user for resolution using `AskUserQuestion`. Process issues in priority order:

1. **Potential Blockers** — these could prevent implementation, resolve first
2. **Open Questions** — ambiguities that affect the plan
3. **Risks** — may need mitigation strategies
4. **Future Considerations** — lowest priority, may be deferred

For each issue:

1. **Explain the context** — briefly describe why this issue matters and how it affects the plan. Reference specific components, files, or decisions from `plan.md` where relevant.
2. **Propose options** — offer 2–4 concrete resolution options via `AskUserQuestion`. Each option should have:
   - A short label describing the choice
   - A description explaining the implications (what changes in the plan, trade-offs, downstream effects)
3. **Include a recommended option** where you have a clear best-practice recommendation. Mark it with "(Recommended)" in the label.
4. **Always allow "Other"** — `AskUserQuestion` provides this automatically for custom input.

**Batching:** Where multiple issues are closely related (e.g. two questions about the same component), present them together in a single `AskUserQuestion` call (up to 4 questions per call). Otherwise, present issues one at a time or in small thematic groups so the user can reason about each without being overwhelmed.

### Step 4: Apply Resolutions

After the user responds to each issue:

1. **Update `issues.md`** — mark the resolved item with the `[RESOLVED]` prefix and append the decision:
   ```
   - [RESOLVED] Original issue text → **Decision:** What was decided. Rationale if non-obvious.
   ```

2. **Update other files as needed** based on what the decision affects:

   - **`plan.md`** — update if the decision changes architecture, component design, file manifest, or approach. Edit the affected sections in place; do not rewrite the entire file. Add or remove components, update notes, adjust the file manifest.
   - **`research.md`** — update if the decision requires recording new findings (e.g. "investigate X" was the decision and the research was done immediately) or if existing research findings need correction.

3. **Do NOT update `prompt.md`** — the original prompt is immutable.

Process all issues before moving to Step 5. If the user defers an issue (e.g. "skip this for now"), leave it unresolved in `issues.md`.

### Step 5: Cross-Check for New Issues

After all resolutions are applied, re-read the updated `plan.md` and `research.md`. Analyze them for:

- **Internal contradictions** — does a resolution in one place conflict with content elsewhere?
- **New gaps** — did a decision open up new questions or expose missing pieces?
- **Stale content** — are there references to things that were changed or removed by a resolution?
- **Feasibility issues** — based on research, do any resolved decisions introduce new technical issues?

If new issues are found:

1. **Add them to `issues.md`** under the appropriate category, as unresolved bullets.
2. **Do NOT present them to the user in this run.** They will be addressed in the next invocation of `pq-review`. This prevents infinite review loops.
3. Note the new issues in the Step 6 report.

### Step 6: Report

Report a summary to the user:

- Number of issues resolved in this run
- Number of issues still open (were open before and user deferred)
- Number of new issues discovered during cross-check
- Which files were modified and a brief note on what changed in each
- If all issues are resolved and no new ones were found, confirm the plan is clean

If there are new or remaining unresolved issues, prompt the user:

> There are still unresolved issues. Run `/pq-review <plan-dir>` again to address them.

If all issues are resolved and no new issues were found:

> All issues are resolved. The plan is ready for task list generation (`/pq-taskify <plan-dir>`) or implementation (`/pq-execute <plan-dir>`).

## Guidelines

- **This is a review and resolution skill, not a re-planning skill.** Do not rewrite or restructure the plan. Make targeted edits to reflect decisions. If a decision fundamentally changes the project direction, recommend the user re-run `pq-plan` instead.
- **Respect settled decisions.** If `prompt.md` contains explicit decisions (e.g. a decisions table), do not re-open them as issues. Only raise issues that are genuinely unresolved or newly discovered.
- **Be opinionated but not prescriptive.** Recommend options where you have expertise, but always let the user choose. Clearly explain trade-offs.
- **Edits should be surgical.** When updating `plan.md`, change only the affected sections. Do not reformat, reorganize, or rewrite surrounding content.
- **Keep `issues.md` as a decision log.** Resolved items remain in the file with their decisions recorded. This provides an audit trail of why choices were made.
- **Do not pad issues.** During cross-check, only add genuinely actionable issues. "This could theoretically be a problem" is not actionable. "This decision contradicts the approach in Component X" is actionable.
- **Idempotent re-runs.** Running this skill when all issues are resolved and no new issues exist should produce no changes and a clean report.
