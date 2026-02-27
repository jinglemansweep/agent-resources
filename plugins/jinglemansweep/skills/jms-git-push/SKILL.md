---
name: jms-git-push
description: Automate branch creation, PR submission, and auto-merge for accidental default-branch commits
allowed-tools: Bash, AskUserQuestion, Read, Glob, Grep
---

# jms-git-push

Automate branch creation, PR submission, and auto-merge for accidental default-branch commits.

## Usage

```text
/jms-git-push
```

No arguments required. Run from within a git repository.

## Instructions

### Step 1: Detect State

Run the following git commands via Bash and capture their output to build a picture of the current repository state.

1. **Verify git repository:**

   ```bash
   git rev-parse --is-inside-work-tree
   ```

   If this fails, abort with a clear error: "Not inside a git repository. Please run this skill from within a git repo."

2. **Check for `gh` CLI:**

   ```bash
   command -v gh
   ```

   If this fails, abort with: "The GitHub CLI (`gh`) is not installed. Install it from <https://cli.github.com/> and authenticate with `gh auth login` before running this skill."

3. **Verify GitHub remote:**

   ```bash
   git remote get-url origin
   ```

   If the URL does not contain `github.com`, abort with: "The `origin` remote does not point to GitHub. This skill requires a GitHub remote."

4. **Get current branch name:**

   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

   Store the result as `CURRENT_BRANCH`.

5. **Determine the default branch:** Check for `origin/main` first, then fall back to `origin/master`:

   ```bash
   git rev-parse --verify --quiet origin/main
   ```

   If this succeeds, the default branch is `main`. If it fails, try:

   ```bash
   git rev-parse --verify --quiet origin/master
   ```

   If this succeeds, the default branch is `master`. If both fail, abort with: "Could not determine the default branch. Neither `origin/main` nor `origin/master` exists." Store the result as `DEFAULT_BRANCH`.

6. **Compare current branch to default branch:** If `CURRENT_BRANCH` equals `DEFAULT_BRANCH`, the user is on the default branch. Otherwise, they are on a feature branch.

7. **Check for uncommitted changes:**

   ```bash
   git status --porcelain
   ```

   If the output is non-empty, there are uncommitted changes (staged or unstaged). Store this as `HAS_UNCOMMITTED_CHANGES`.

8. **Count commits ahead of remote:**

   ```bash
   git rev-list @{upstream}..HEAD --count
   ```

   If this fails (no upstream set), treat as 0 commits ahead for feature branches without tracking. Store the result as `COMMITS_AHEAD`.

9. **If on the default branch**, check whether ahead-of-remote commits have already been pushed:

   ```bash
   git rev-parse HEAD
   git rev-parse origin/<DEFAULT_BRANCH>
   ```

   If both values match, there are no unpushed commits. If `HEAD` is ahead, verify the commits have not already been pushed by checking:

   ```bash
   git branch -r --contains HEAD
   ```

   If the output includes `origin/<DEFAULT_BRANCH>`, abort with: "Commits have already been pushed to the remote default branch. This skill cannot safely relocate pushed commits. Please handle this manually."

10. **No unpushed commits on default branch:** If on the default branch and `COMMITS_AHEAD` is 0 (or HEAD matches the remote), check `HAS_UNCOMMITTED_CHANGES`. If there are no uncommitted changes either, inform the user: "There are no unpushed commits and no uncommitted changes on the default branch. Nothing to do." If there are uncommitted changes but no commits ahead, note this -- the workflow will still create a branch, commit the changes, and open a PR.

11. **Summarise the detected state** to the user before proceeding. Include: current branch, default branch, number of unpushed commits, and whether uncommitted changes exist.

### Step 2: Branch Creation (Default Branch Path)

**Only execute this step when the user is on the default branch with unpushed commits or uncommitted changes.**

1. **Stash uncommitted changes** if `HAS_UNCOMMITTED_CHANGES` is true:

   ```bash
   git stash --include-untracked
   ```

   Note that a stash was created. This will be popped later.

2. **Generate 2--3 branch name suggestions.** Read the commit subjects and changed files:

   ```bash
   git log origin/<DEFAULT_BRANCH>..HEAD --format='%s'
   git diff --name-only origin/<DEFAULT_BRANCH>..HEAD
   ```

   From this information, derive short slugs of 2--4 hyphen-separated words based on the most descriptive commit subject. Prefix each suggestion with `feat/`, `fix/`, or `chore/` by inferring from keywords in the commit messages:

   - Commit message contains "fix", "bug", "patch", "resolve" -> `fix/`
   - Commit message contains "add", "implement", "create", "new", "feature" -> `feat/`
   - Otherwise -> `chore/`

   If there are no commits ahead (only uncommitted changes), derive the slug from a brief description of the uncommitted changes (e.g. from the file names in `git status --porcelain`).

3. **Present suggestions to the user** via `AskUserQuestion`. Offer the generated names as options. The user can also type a custom name via "Other".

4. **Create the new branch** at the current HEAD:

   ```bash
   git branch <chosen-name>
   ```

5. **Reset the default branch** to match the remote:

   ```bash
   git reset --hard origin/<DEFAULT_BRANCH>
   ```

6. **Switch to the new branch:**

   ```bash
   git switch <chosen-name>
   ```

7. **Pop the stash** if one was created:

   ```bash
   git stash pop
   ```

   If this fails (exit code non-zero), warn the user: "Stash could not be applied cleanly -- your changes are still saved in `git stash`. Run `git stash pop` manually after resolving conflicts." Do **not** abort -- the branch creation and commit relocation have succeeded.

### Step 3: Feature Branch Path

**Only execute this step when the user is already on a non-default branch.**

1. If there are uncommitted changes, note them -- they will be committed in the next step.
2. Skip branch creation entirely and proceed directly to **Step 4: Commit & Push**.

### Step 4: Commit & Push

1. **Stage and commit uncommitted changes** if `HAS_UNCOMMITTED_CHANGES` is true (from the original state detection, or from a stash pop):

   ```bash
   git add -A
   ```

   Generate a concise commit message by inspecting the staged diff summary:

   ```bash
   git diff --cached --stat
   ```

   Use the stat output to write a short, descriptive commit message. Commit:

   ```bash
   git commit -m "<message>"
   ```

   Do **NOT** include `Co-Authored-By` or any authoring annotations in the commit message.

2. **Push the branch** with upstream tracking:

   ```bash
   git push -u origin <branch-name>
   ```

   If the push fails, report the error to the user and **stop**. Do not proceed to PR creation.

### Step 5: Create Pull Request

1. **Check for an existing PR** for this branch:

   ```bash
   gh pr list --head <branch-name> --state open --json number,url
   ```

   If a PR already exists, skip creation and report the existing PR URL. Proceed to **Step 6**.

2. **Generate PR title and body.** Use the most significant commit subject as the title:

   ```bash
   git log origin/<DEFAULT_BRANCH>..HEAD --format='%s' | head -1
   ```

   Generate the body as a summary of all commits:

   ```bash
   git log origin/<DEFAULT_BRANCH>..HEAD --format='- %s'
   ```

   Do **NOT** include `Co-Authored-By` or authoring annotations in the title or body.

3. **Create the PR** using a HEREDOC for the body to handle multiline content and special characters:

   ```bash
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   <body content>
   EOF
   )" --base <DEFAULT_BRANCH>
   ```

4. Capture and report the PR URL from the command output.

### Step 6: Enable Auto-Merge

1. Run:

   ```bash
   gh pr merge --auto --squash --delete-branch <pr-url>
   ```

   Always use `--squash` (no user prompt for merge strategy). Include `--delete-branch` to clean up the remote branch after merge.

2. If the command succeeds, report that auto-merge is enabled and the PR will merge automatically after CI passes.

3. If the command fails (exit code non-zero), treat this as **non-fatal**. Inform the user: "Auto-merge could not be enabled. This usually means auto-merge is not enabled in the repository settings. Go to Settings -> General -> Pull Requests -> Allow auto-merge to enable it. Your PR has still been created successfully." Continue without error.

### Step 7: Summary

Print a final summary to the user including:

- **Branch name** -- the branch that was created or used.
- **Number of commits** -- total commits on the branch ahead of the default branch.
- **PR URL** -- linked so the user can click through.
- **Auto-merge status** -- whether auto-merge was successfully enabled.
- **Warnings** -- any warnings that occurred during the process (stash conflicts, auto-merge not available, etc.).

## Edge Cases

- **Not in a git repository** -- Detected in Step 1 via `git rev-parse --is-inside-work-tree`. Abort immediately with a clear message.
- **No commits ahead of remote on default branch** -- If there are no unpushed commits and no uncommitted changes, inform the user there is nothing to do. If there are uncommitted changes but no commits ahead, proceed with the workflow: create a branch, commit the changes, and open a PR.
- **Commits already pushed to remote default branch** -- Detected in Step 1 by comparing `HEAD` with `origin/<default>` and checking `git branch -r --contains HEAD`. Abort with: "Commits have already been pushed to the remote default branch. This skill cannot safely relocate pushed commits. Please handle this manually." No force-push is ever performed.
- **No `gh` CLI available** -- Detected in Step 1 via `command -v gh`. Abort with install instructions pointing to <https://cli.github.com/>.
- **No GitHub remote** -- Detected in Step 1 by checking `git remote get-url origin`. If the URL does not contain `github.com`, abort with a clear message that this skill requires a GitHub remote.
