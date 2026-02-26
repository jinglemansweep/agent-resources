---
name: jms-phase-new
description: Create a new datestamped planning phase directory with sequential numbering
allowed-tools: AskUserQuestion, Bash, Glob, Write
---

# jms-phase-new

Create a new planning phase directory with a datestamped path and sequential numbering.

## Usage

```
/jms-phase-new <description>
```

**Argument:**
- `<description>` — A concise description of this planning phase (e.g. "auth-refactor", "api-endpoints", "bug-fixes"). Keep it to 2-3 essential words — omit articles, prepositions, and filler words.

## Instructions

### Step 1: Validate

Ensure the `.plans` directory exists in the repository root. If not, stop and tell the user to run `/jms-init` first.

### Step 2: Check Git Branch

Check the current git branch. If on `main` or `master`, suggest creating a new feature branch before proceeding. Derive the suggested branch name from the phase description slug using the format `plan/<slug>` (e.g. `plan/auth-implementation`).

Use `AskUserQuestion` to ask the user whether they want to:
1. **Create the suggested branch** (recommended) — create and switch to the new branch before continuing.
2. **Stay on the current branch** — skip branch creation and continue on main/master.

If the user is already on a non-main/master branch, skip this step silently.

### Step 3: Determine Date Directory

Get today's date formatted as `YYYYMMDD` (e.g. `20260115`). The date directory is `.plans/YYYYMMDD/`.

Create the date directory if it does not already exist.

### Step 4: Determine Phase Number

List existing subdirectories in the date directory. Each subdirectory is expected to be prefixed with a two-digit number (e.g. `01-initial-implementation`, `02-fixes`).

Calculate the next sequential number:
- If no subdirectories exist, the next number is `01`.
- If subdirectories exist, find the highest existing number prefix and add 1 (e.g. if `02-fixes` exists, next is `03`).
- Format as two digits with leading zero (e.g. `01`, `02`, `03`).

### Step 5: Create Phase Directory

Convert the description to a concise, filename-friendly slug:
- Remove stop words (articles, prepositions, conjunctions: a, an, the, of, for, to, in, on, at, by, with, and, or, but, is, it, this, that, from, into, etc.)
- Convert to lowercase
- Replace spaces and underscores with hyphens
- Remove any characters that are not alphanumeric or hyphens
- Collapse multiple consecutive hyphens into one
- Trim leading/trailing hyphens
- Target 2-3 words in the final slug — if it's still longer than 3 hyphenated segments after stop-word removal, distill to the most essential terms

Create the directory: `.plans/YYYYMMDD/NN-<slug>/`

**Examples:**
- "testing the plan workflow" → `01-plan-workflow-testing`
- "initial implementation of auth" → `01-auth-implementation`
- "add user registration endpoints" → `01-registration-endpoints`
- "bug fixes" → `01-bug-fixes`

### Step 6: Create Prompt File

Create an empty `prompt.md` file inside the new phase directory. This file is the starting point for the planning workflow — the user will write their requirements here before running `/jms-plan`.

### Step 7: Report

Report the full path of the created phase directory to the user, and remind them to write their requirements in `prompt.md` before running `/jms-plan`.
