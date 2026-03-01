# Implementation Plan

> Source: `.plans/20260227/02-github-skill/prompt.md`

## Overview

A new `jms-git-push` skill that automates the common post-development workflow of moving accidental commits off a default branch, creating a feature branch, pushing, creating a PR, and enabling auto-merge. The skill handles the entire flow interactively, detecting the current state and guiding the user through each decision point.

## Architecture & Approach

The skill is a single `SKILL.md` file following the existing jinglemansweep plugin conventions. It operates entirely through git and `gh` CLI commands executed via the Bash tool, with `AskUserQuestion` for interactive decisions.

The core flow has two distinct paths depending on the detected state:

1. **On default branch with unpushed commits** — The primary use case. The skill creates a new branch from the current HEAD, resets the default branch to match the remote, switches to the new branch, stages/commits any uncommitted changes, pushes, creates a PR, and enables auto-merge.

2. **Already on a feature branch** — A simpler path. The skill stages/commits uncommitted changes (if any), pushes the branch, creates a PR if one doesn't exist, and enables auto-merge.

The skill must detect and handle several edge states: uncommitted changes in the working directory, commits that have already been pushed to the default branch (which cannot be safely moved), and repositories where auto-merge is not enabled.

Branch name suggestions are derived from commit messages and staged file paths to give the user meaningful defaults. PR title and body are generated from the commit log, respecting the user's rule of no authoring annotations.

## Components

### State Detection

**Purpose:** Determine the current git state to decide which workflow path to follow.
**Inputs:** Current working directory (must be a git repository).
**Outputs:** A set of state facts: current branch name, whether it's a default branch, number of commits ahead of remote, whether those commits are pushed, whether there are uncommitted changes.
**Notes:** Uses `git rev-parse --abbrev-ref HEAD` for branch name, `git rev-list @{upstream}..HEAD` for unpushed commit count, and `git status --porcelain` for uncommitted changes. Must handle the case where no upstream is set (fresh repo or branch without tracking). Must also detect whether commits on the default branch have already been pushed to the remote — if so, the skill aborts with a clear explanation rather than attempting any destructive operations.

### Branch Creation & Commit Relocation

**Purpose:** Create a new feature branch and move accidental commits off the default branch.
**Inputs:** Current HEAD (with commits to move), user-chosen branch name.
**Outputs:** A new branch containing the commits; default branch reset to match remote.
**Notes:** The safe pattern is: `git branch <new-name>` (creates branch at current HEAD), then `git reset --hard` to the remote tracking ref (e.g. `origin/main`), then `git switch <new-name>`. This only works for unpushed commits. If commits have been pushed to the remote default branch, the skill aborts with a clear explanation — no force-push or revert is attempted. Uncommitted changes are stashed before the reset. If `git stash pop` fails after switching (due to merge conflicts), the skill leaves changes in the stash, warns the user, and instructs them to run `git stash pop` manually. The branch creation and commit relocation still succeed in this case.

### Branch Name Suggestion

**Purpose:** Offer the user meaningful branch name suggestions based on their work.
**Inputs:** Commit messages, changed file paths.
**Outputs:** 2-3 suggested branch names in the format `feat/<slug>`, `fix/<slug>`, or `chore/<slug>`.
**Notes:** Extract keywords from the first commit message subject line. Fall back to directory/file patterns if commit messages are generic. Present suggestions via `AskUserQuestion` with an "Other" option for custom input. Keep slugs concise (2-4 words, hyphen-separated).

### Commit & Push

**Purpose:** Stage any uncommitted changes, create a commit if needed, and push the branch.
**Inputs:** The current feature branch with changes.
**Outputs:** Branch pushed to remote with tracking set.
**Notes:** If there are uncommitted changes, generate a concise commit message from the diff summary. Use `git push -u origin <branch>` to set upstream tracking. No `Co-Authored-By` or other authoring annotations in commit messages, per user rules.

### PR Creation

**Purpose:** Create a GitHub pull request from the feature branch to the default branch.
**Inputs:** Branch name, commit log, default branch name.
**Outputs:** A PR with a descriptive title and body.
**Notes:** Use `gh pr create --title <title> --body <body> --base <default-branch>`. Generate the title from the most significant commit message. Generate the body as a summary of all commits with a brief description of changes. No authoring annotations. Check if a PR already exists for this branch first (`gh pr list --head <branch>`) to avoid duplicates.

### Auto-Merge

**Purpose:** Enable auto-merge on the created PR so it merges after CI passes.
**Inputs:** PR URL or number.
**Outputs:** Auto-merge enabled on the PR.
**Notes:** Use `gh pr merge --auto --squash <pr>`. Always use `--squash` — no user prompt for merge strategy. If auto-merge fails (not enabled on repo), catch the error, inform the user how to enable auto-merge in GitHub repository settings, and continue — this is non-fatal, the PR is still created successfully. Consider also passing `--delete-branch` to clean up after merge.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `plugins/jinglemansweep/skills/jms-git-push/SKILL.md` | Create | The skill definition with full step-by-step instructions |
| `plugins/jinglemansweep/plugin.json` | Modify | Register `jms-git-push` in the skills array |
| `plugins/jinglemansweep/install.sh` | No change | Already copies all skills dynamically via glob pattern |
| `README.md` | Modify | Add `jms-git-push` to the skill listing and directory tree |
| `.agentmap.yaml` | Modify | Add `jms-git-push` skill entry under the jinglemansweep skills tree |
