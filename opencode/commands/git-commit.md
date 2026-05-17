---
description: Commit, push, and open a PR
---

You are creating a git commit and pull request. Follow these steps:

1. **Check branch** — Run `git branch --show-current`. If the result
   is `main` or `master`, derive a branch name from the changes:

   - Analyze the diff to determine the prefix (`feat`, `fix`,
     `chore`, `docs`) and a short hyphen-separated slug.
   - Present the recommended name (e.g. `feat/add-cool-feature`)
     and ask the user to confirm or override it.
   - Create and switch to the new branch:
     `git checkout -b <prefix>/<slug>`

2. **Understand changes** — Run `git status`, `git diff --staged`,
   and `git diff` to understand what has changed. Identify the scope
   of changes — which files and what they do.

3. **Run quality gates** — First read `AGENTS.md` and `README.md` to
   discover project-specific requirements and test commands. Then:

   - If a `.pre-commit-config.yaml` exists, run
     `pre-commit run --all-files`. Fix any failures before
     proceeding.
   - If no pre-commit config, detect the language/framework and run
     the appropriate linters:
     - Nix: `nix run nixpkgs#statix -- check .` and
       `nix run nixpkgs#deadnix -- --fail
       --no-lambda-pattern-names .`
     - Python: `ruff check .` or the project's configured linter
     - JavaScript/TypeScript: `npm run lint` or `npx eslint .`
     - Go: `go vet ./...` and `golangci-lint run`
   - Run any project-specific test commands discovered from
     `AGENTS.md` / `README.md` (e.g. `pytest`, `npm run test`).
   - If `nix flake check` is applicable (project has a `flake.nix`),
     run it as a final validation.
   - If any quality gate fails, fix the issues and re-run until all
     pass.

4. **Stage files** — Run `git add -A` to stage all modified and new
   files. Review `git diff --staged` to confirm only intended changes
   are included. Unstage anything that should not be committed
   (secrets, large generated files, etc.).

5. **Commit** — Create a commit with a descriptive message that:
   - Uses the imperative mood (e.g. "Add", "Fix", "Refactor")
   - Focuses on the "why" rather than the "what"
   - Is 1-2 sentences, concise but informative
   - Follows the style of recent commits in
     `git log --oneline -5`

6. **Push** — Push the branch to the remote:
   `git push -u origin HEAD`

7. **Create a pull request** — Use `gh pr create` with a title and
   body that summarize the changes. The title should match the commit
   message style. The body should include:
   - A brief summary of what changed and why
   - Any notable implementation details
   - A reference to related issues if applicable

8. Report the PR URL to the user.
