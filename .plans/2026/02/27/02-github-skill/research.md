# Research

> Source: `.plans/20260227/02-github-skill/prompt.md`

## GitHub CLI (`gh`) — PR Creation

- **URL:** https://cli.github.com/manual/gh_pr_create
- **Status:** Actively maintained
- **Latest Version:** 2.x (current stable)
- **Compatibility:** Available via standard package managers; invoked via Bash in skills
- **Key Findings:**
  - `--title` (`-t`) and `--body` (`-b`) set PR title and description
  - `--body-file` (`-F`) reads body from a file (useful for longer descriptions)
  - `--base` (`-B`) sets the target branch (defaults to repo default branch)
  - `--head` (`-H`) sets the source branch
  - `--fill` (`-f`) auto-populates title/body from commit messages; explicit `--title`/`--body` override filled values
  - `--label`, `--reviewer`, `--assignee`, `--milestone`, `--project` for metadata
  - `--draft` creates a draft PR
  - `--web` opens the browser form instead of CLI creation
- **Concerns:** None — well-established tool, already used in the project's conventions
- **Integration Verification:** No known issues with Claude Code Bash tool usage; `gh` is a standard CLI tool

## GitHub CLI (`gh`) — Auto-Merge

- **URL:** https://cli.github.com/manual/gh_pr_merge
- **Status:** Actively maintained
- **Key Findings:**
  - `--auto` enables auto-merge — waits for required checks to pass, then merges
  - Requires a merge strategy flag: `--merge` (`-m`), `--rebase` (`-r`), or `--squash` (`-s`)
  - Exception: merge queue-enabled branches do not need a strategy flag
  - `--disable-auto` turns off auto-merge
  - `--delete-branch` (`-d`) deletes local and remote branches after merge
- **Concerns:**
  - **Auto-merge must be enabled in repository settings** — if not enabled, the command will fail
  - Branch protection rules may block merge unless `--admin` is used
  - The skill should handle the case where auto-merge is not enabled on the repo
- **Integration Verification:** `gh pr merge --auto --squash <pr-url>` is the most common pattern for single-commit PRs

## Git — Moving Commits Between Branches

- **URL:** https://git-scm.com/docs/git-reset
- **Status:** Core git functionality
- **Key Findings:**
  - Safe pattern for unpushed commits: `git branch <new>` then `git reset --hard HEAD~N` on the original branch
  - This works because branches are just pointers — commits remain on the new branch
  - `git reflog` provides a safety net for ~30 days after reset
  - For pushed commits, `git revert` is safer but creates revert commits on the default branch
  - `git switch -c <new>` is the modern equivalent of `git checkout -b <new>` (git 2.23+)
- **Concerns:**
  - **Pushed commits cannot be safely moved with reset** — requires force-push to main which is destructive
  - The skill must distinguish between pushed and unpushed commits
  - Uncommitted working directory changes must be handled (stash or abort)
- **Integration Verification:** Standard git operations, no integration issues

## Compatibility Matrix

| Component A | Component B | Status | Notes |
|-------------|-------------|--------|-------|
| `gh pr create` | `gh pr merge --auto` | Compatible | Can be run sequentially; `gh pr create` returns PR URL for use with merge |
| `git reset` | `gh` CLI | Compatible | Reset is local; `gh` operates on remote — no conflict |
| `git branch` + `reset` | Pushed commits | Conflict | Cannot safely reset pushed commits on shared branches; skill must detect this |

## Licence Summary

| Dependency | Licence | Compatibility Notes |
|------------|---------|---------------------|
| `gh` CLI | MIT | Compatible with GPL-3.0 project licence |
| `git` | GPL-2.0 | Compatible with GPL-3.0 project licence |
