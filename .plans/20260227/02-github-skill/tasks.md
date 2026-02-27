# Task List

> Source: `.plans/20260227/02-github-skill/plan.md`

## Skill Definition

### SKILL.md Structure & Front Matter

- [x] **Create `plugins/jinglemansweep/skills/jms-git-push/SKILL.md` with front matter and overview** — Create the file `plugins/jinglemansweep/skills/jms-git-push/SKILL.md`. Add YAML front matter matching the existing skill format: `name: jms-git-push`, `description: Automate branch creation, PR submission, and auto-merge for accidental default-branch commits`, `allowed-tools: Bash, AskUserQuestion, Read, Glob, Grep`. Add a top-level heading `# jms-git-push`, a one-line summary, and a `## Usage` section showing `/jms-git-push` with no arguments. Reference existing skills like `plugins/jinglemansweep/skills/jms-execute/SKILL.md` for format conventions.

### State Detection Instructions

- [x] **Write the state detection step in SKILL.md** — Add a `## Instructions` section and `### Step 1: Detect State` to the SKILL.md. The step must instruct the agent to run the following git commands via Bash and capture their output:
  - `git rev-parse --is-inside-work-tree` — abort with an error if not in a git repo.
  - `git rev-parse --abbrev-ref HEAD` — get the current branch name.
  - Determine the default branch: check for `origin/main` then `origin/master` using `git rev-parse --verify --quiet origin/main` (fall back to `origin/master`).
  - Compare current branch to the default branch name to decide if on the default branch.
  - `git status --porcelain` — check for uncommitted changes (staged or unstaged).
  - `git rev-list @{upstream}..HEAD --count` — count commits ahead of remote. Handle the case where no upstream is set (treat as 0 ahead for feature branches without tracking).
  - If on the default branch: check whether those ahead-of-remote commits have been pushed by comparing `git rev-parse HEAD` with `git rev-parse origin/<default>`. If they match, there are no unpushed commits. If `HEAD` is ahead and those commits exist on the remote (i.e. `git branch -r --contains HEAD` includes `origin/<default>`), abort with a clear message: "Commits have already been pushed to the remote default branch. This skill cannot safely relocate pushed commits. Please handle this manually."
  - Summarise the detected state to the user before proceeding.

### Workflow Path: Default Branch

- [x] **Write the default-branch workflow path in SKILL.md** — Add `### Step 2: Branch Creation (Default Branch Path)` with instructions that only execute when the user is on the default branch with unpushed commits. The step must:
  - If there are uncommitted changes, run `git stash --include-untracked` and note that a stash was created.
  - Generate 2–3 branch name suggestions by: reading the commit subjects with `git log origin/<default>..HEAD --format='%s'` and the changed file paths with `git diff --name-only origin/<default>..HEAD`. Derive short slugs (2–4 hyphen-separated words) from the most descriptive commit subject. Prefix with `feat/`, `fix/`, or `chore/` — infer the prefix from keywords in commit messages (e.g. "fix" → `fix/`, "add"/"implement" → `feat/`, otherwise `chore/`).
  - Present suggestions via `AskUserQuestion` with the generated names as options (the user can also type a custom name via "Other").
  - Run `git branch <chosen-name>` to create the new branch at the current HEAD.
  - Run `git reset --hard origin/<default>` to reset the default branch to match the remote.
  - Run `git switch <chosen-name>` to move to the new branch.
  - If a stash was created, run `git stash pop`. If this fails (exit code non-zero), warn the user: "Stash could not be applied cleanly — your changes are still saved in `git stash`. Run `git stash pop` manually after resolving conflicts." Do not abort — the branch creation and commit relocation have succeeded.

- [x] **Write the feature-branch workflow path in SKILL.md** — Add `### Step 3: Feature Branch Path` with instructions that execute when the user is already on a non-default branch. This is a simpler path:
  - If there are uncommitted changes, note them — they will be committed in the next step.
  - Skip branch creation entirely and proceed directly to commit and push.

### Commit, Push & PR

- [x] **Write the commit and push step in SKILL.md** — Add `### Step 4: Commit & Push` with instructions to:
  - If there are uncommitted changes (from state detection or stash pop): run `git add -A` to stage all changes. Generate a concise commit message from the diff summary (use `git diff --cached --stat` to inform the message). Commit with `git commit -m "<message>"`. Do NOT include `Co-Authored-By` or any authoring annotations in the commit message.
  - Push the branch: run `git push -u origin <branch-name>`. The `-u` flag sets upstream tracking.
  - If the push fails, report the error and stop.

- [x] **Write the PR creation step in SKILL.md** — Add `### Step 5: Create Pull Request` with instructions to:
  - First check if a PR already exists for this branch: run `gh pr list --head <branch-name> --state open --json number,url`. If a PR exists, skip creation and report the existing PR URL.
  - If no PR exists, generate a PR title from the most significant commit message subject (use `git log origin/<default>..HEAD --format='%s' | head -1`). Generate the PR body as a brief summary of all commits (use `git log origin/<default>..HEAD --format='- %s'`). Do NOT include `Co-Authored-By` or authoring annotations in the title or body.
  - Create the PR: run `gh pr create --title "<title>" --body "<body>" --base <default-branch>`. Use a HEREDOC for the body to handle multiline content and special characters.
  - Capture and report the PR URL from the command output.

- [x] **Write the auto-merge step in SKILL.md** — Add `### Step 6: Enable Auto-Merge` with instructions to:
  - Run `gh pr merge --auto --squash --delete-branch <pr-url>`. Always use `--squash` (no user prompt for merge strategy). Include `--delete-branch` to clean up the remote branch after merge.
  - If the command succeeds, report that auto-merge is enabled and the PR will merge automatically after CI passes.
  - If the command fails (exit code non-zero), treat this as non-fatal. Inform the user: "Auto-merge could not be enabled. This usually means auto-merge is not enabled in the repository settings. Go to Settings → General → Pull Requests → Allow auto-merge to enable it. Your PR has still been created successfully." Continue without error.

### Summary & Edge Cases

- [x] **Write the summary step in SKILL.md** — Add `### Step 7: Summary` with instructions to print a final summary to the user including: the branch name, number of commits, PR URL (linked), whether auto-merge was enabled, and any warnings that occurred (stash conflicts, auto-merge not available).

- [x] **Add edge case handling notes to SKILL.md** — Add a `## Edge Cases` section at the end of the SKILL.md documenting how the skill handles:
  - Not in a git repository → abort with clear message.
  - No commits ahead of remote on default branch → inform user there's nothing to relocate and offer to just push uncommitted changes on a new branch if any exist.
  - Commits already pushed to remote default branch → abort with explanation (no force-push).
  - No `gh` CLI available → detect with `command -v gh` at the start of the skill and abort with install instructions if missing.
  - No GitHub remote → detect by checking `git remote get-url origin` and abort if it doesn't point to GitHub.

## Plugin Registration & Documentation

- [ ] **Add `jms-git-push` to `plugins/jinglemansweep/plugin.json`** — Edit `plugins/jinglemansweep/plugin.json` and add `"jms-git-push"` to the `skills` array. Insert it after `"jms-execute"` (the last current entry) to maintain logical ordering. The resulting array should be: `["jms-init", "jms-phase-new", "jms-plan", "jms-review", "jms-taskify", "jms-execute", "jms-git-push"]`.

- [ ] **Update `README.md` with `jms-git-push`** — Edit `README.md` in two places:
  - In the **Directory Structure** section, add `jms-git-push/` under `skills/` in the tree listing, after `jms-execute/`.
  - In the **jinglemansweep Skills** list, add a new bullet: `` `jms-git-push` — Automate branch creation, PR submission, and auto-merge for accidental default-branch commits ``.

- [ ] **Update `.agentmap.yaml` with `jms-git-push`** — Edit `.agentmap.yaml` and add a new entry under `tree.plugins/.jinglemansweep/.skills/`: `jms-git-push/: "skill: automate branch creation, PR, and auto-merge"`. Insert it after the `jms-execute/` entry.
