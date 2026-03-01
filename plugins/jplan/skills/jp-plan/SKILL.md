---
name: jp-plan
description: Create a new datestamped planning phase directory with sequential numbering and conventional branch naming
allowed-tools: AskUserQuestion, Bash, Edit, Glob, Read, Write
---

# jp-plan

Create a new planning phase directory with a nested datestamped path, sequential numbering, structured prompt template, and state tracking.

## Usage

```text
/jp-plan <description>
```

**Argument:**

- `<description>` -- A concise description of this planning phase (e.g. "auth-refactor", "api-endpoints", "bug-fixes"). Keep it to 2-3 essential words -- omit articles, prepositions, and filler words.

## Instructions

### Step 0: Determine Repository Root

Run `git rev-parse --show-toplevel` to determine the repository root. All `.plans/` references in this skill resolve relative to this root (i.e. `<repo-root>/.plans/`). If the command fails (not a git repository), stop and tell the user this skill requires a git repository.

### Step 1: Validate

Ensure the `<repo-root>/.plans` directory exists. If not, stop and tell the user to run `/jp-setup` first.

### Step 2: Check Git Branch

Check the current git branch. If the user is already on a non-main/master branch, skip this step silently and record the current branch name for use in Step 12.

If on `main` or `master`, suggest creating a new branch before proceeding. Derive the suggested branch name using a **conventional prefix** based on keywords in the phase description:

| Keywords in description | Suggested prefix |
|---|---|
| fix, bug, patch, hotfix, repair, resolve | `fix/` |
| docs, documentation, readme, changelog | `docs/` |
| test, testing, spec, coverage | `test/` |
| refactor, restructure, reorganize, cleanup, clean-up | `refactor/` |
| chore, config, ci, lint, format, bump, dependency, deps | `chore/` |
| *(anything else / default)* | `feat/` |

Match keywords case-insensitively against the description. If multiple prefixes match, prefer the first match in table order.

The suggested branch name format is `<prefix><slug>` (e.g. `feat/auth-implementation`, `fix/login-crash`).

Use `AskUserQuestion` to present the suggestion and ask the user to choose one of:

1. **Create the suggested branch** (recommended) -- create and switch to the new branch.
2. **Edit the branch name** -- let the user type a different name.
3. **Stay on the current branch** -- skip branch creation and continue on main/master.

Record the active branch name (whether newly created or existing) for use in Step 12.

#### Example Interaction

```text
You are on `main`. I suggest creating a branch for this phase:

  Suggested branch: feat/auth-implementation

Options:
  1. Create `feat/auth-implementation` (recommended)
  2. Enter a different branch name
  3. Stay on `main`
```

If the user chooses option 2:

```text
Enter your preferred branch name:
> fix/auth-session-bug

Creating and switching to `fix/auth-session-bug`...
```

### Step 3: Determine Date Directory

Get today's date. The date directory uses **nested year/month/day** format:

```text
.plans/YYYY/MM/DD/
```

For example, January 15 2026 produces `.plans/2026/01/15/`.

Create the nested directories if they do not already exist.

### Step 4: Determine Phase Number

List existing subdirectories in the date directory (`.plans/YYYY/MM/DD/`). Each subdirectory is expected to be prefixed with a two-digit number (e.g. `01-initial-implementation`, `02-fixes`).

Calculate the next sequential number:

- If no subdirectories exist, the next number is `01`.
- If subdirectories exist, find the highest existing number prefix and add 1 (e.g. if `02-fixes` exists, next is `03`).
- Format as two digits with leading zero (e.g. `01`, `02`, `03`).

### Step 5: Create Phase Directory and Subdirectories

Convert the description to a concise, filename-friendly slug:

- Remove stop words (articles, prepositions, conjunctions: a, an, the, of, for, to, in, on, at, by, with, and, or, but, is, it, this, that, from, into, etc.)
- Convert to lowercase
- Replace spaces and underscores with hyphens
- Remove any characters that are not alphanumeric or hyphens
- Collapse multiple consecutive hyphens into one
- Trim leading/trailing hyphens
- Target 2-3 words in the final slug -- if it is still longer than 3 hyphenated segments after stop-word removal, distill to the most essential terms

Create the phase directory and its required subdirectories:

```text
.plans/YYYY/MM/DD/NN-<slug>/
.plans/YYYY/MM/DD/NN-<slug>/reviews/
.plans/YYYY/MM/DD/NN-<slug>/reviews/cycle/
```

**Examples:**

- "testing the plan workflow" on 2026-03-01 --> `.plans/2026/03/01/01-plan-workflow-testing/`
- "initial implementation of auth" on 2026-01-15 --> `.plans/2026/01/15/01-auth-implementation/`
- "add user registration endpoints" on 2026-06-22 --> `.plans/2026/06/22/01-registration-endpoints/`
- "bug fixes" on 2026-03-01 --> `.plans/2026/03/01/01-bug-fixes/`

### Step 6: Create Prompt File

Create `prompt.md` inside the new phase directory with the following structured template:

```markdown
# Phase: NN-<slug>

## Overview

<!-- Briefly describe what this phase is about and why it is needed. -->

## Goals

<!-- List the specific goals this phase aims to achieve. -->

## Requirements

<!-- Detail the functional and non-functional requirements. -->

## Constraints

<!-- List any technical, time, or resource constraints. -->

## Out of Scope

<!-- Explicitly state what is NOT part of this phase. -->

## References

<!-- Link to related issues, documents, discussions, or prior work. -->
```

Replace `NN-<slug>` in the heading with the actual phase directory name (e.g. `01-auth-implementation`).

### Step 7: Prompt Ingestion

Use `AskUserQuestion` to ask the user whether they have finished writing their prompt content. Present two options:

1. **"I've finished editing prompt.md"** (recommended) -- proceed with the prompt review.
2. **"Skip prompt review"** -- bypass the review entirely and jump directly to the state file step (Step 11).

If the user chooses to skip, proceed immediately to Step 11 (Initialize State File) without performing Steps 8-10.

If the user confirms they have finished editing, use the Read tool to read the full contents of `prompt.md` into context before continuing to Step 8.

### Step 8: High-Level Prompt Review

Perform a lightweight scan of the ingested `prompt.md` content. For each section (Overview, Goals, Requirements, Constraints, Out of Scope, References), check for:

- **Empty or placeholder-only sections** -- the section contains no user-written content and only has the original HTML comment placeholder (e.g. `<!-- Briefly describe what this phase is about and why it is needed. -->`).
- **Obvious contradictions between sections** -- for example, a goal that directly conflicts with an out-of-scope item, or a constraint that contradicts a requirement.

Build a list of identified gaps from these checks.

**Important:** Do NOT perform deep requirements analysis, suggest additional requirements, question the user's technical decisions, or evaluate the quality of the content. This step is limited to detecting clear omissions and contradictions only.

If no gaps are found, skip Steps 9 and 10 and proceed directly to Step 11 (Initialize State File) with a brief note to the user that the prompt looks complete.

### Step 9: Interactive Interview

If gaps were identified in Step 8, present them to the user as a brief interview using `AskUserQuestion`. Group all gaps into a single interaction where possible -- aim for 1-3 questions and never exceed 5. Each question should:

- Clearly identify what is missing or contradictory.
- Ask the user to either provide the missing content or explicitly dismiss the gap (e.g. "intentionally left blank").

The entire interview must complete in one round of questions and one round of answers. Do not ask follow-up questions or start a second round.

### Step 10: Update prompt.md

If the user provided content for any gaps during the interview in Step 9, use the Edit tool to update `prompt.md` in place:

- Replace the HTML comment placeholders in the relevant sections with the user's responses.
- Preserve all existing user-written content -- only fill gaps or apply corrections.
- Maintain the same Markdown structure and heading hierarchy.

If the user dismissed all gaps (nothing to change), do not modify `prompt.md`. Note in the final report (Step 12) that the prompt was reviewed but no updates were applied.

### Step 11: Initialize State File

Create `state.yaml` inside the new phase directory with the following content:

```yaml
status: pending
phase_path: .plans/YYYY/MM/DD/NN-<slug>
branch: <active-branch-name>
```

Replace the placeholder values with the actual phase path and the active branch name recorded in Step 2.

### Step 12: Report

Report the following to the user:

- The full path of the created phase directory
- The branch that is active (newly created or existing)
- A reminder to write their requirements in `prompt.md` before running `/jp-prd`
- A note that `reviews/` and `reviews/cycle/` subdirectories have been created for later pipeline stages
- Whether `prompt.md` was reviewed and what updates (if any) were applied during the prompt review step
