# Issues

> Source: `.plans/20260227/02-github-skill/prompt.md`

## Open Questions

- [RESOLVED] **Merge strategy preference:** The plan assumes `--squash` for auto-merge. Should the skill default to squash, or ask the user each time? → **Decision:** Always use `--squash`. Cleanest for single-feature branches and matches the typical workflow.
- [RESOLVED] **Branch name prefix convention:** The plan suggests `feat/`, `fix/`, `chore/` prefixes. Does the user have a preferred branch naming convention? → **Decision:** Use `feat/`, `fix/`, `chore/` prefixes as defaults. Infer prefix from commit messages where possible.
- [RESOLVED] **Scope of "set of skills":** The prompt mentions "a set of Agent Skills" but then focuses on one (`jms-git-push`). → **Decision:** This phase covers `jms-git-push` only. Additional git skills can be planned in a future phase.

## Potential Blockers

- [RESOLVED] **Commits already pushed to remote default branch:** The skill cannot safely relocate pushed commits. → **Decision:** Detect and abort. The skill checks if commits have been pushed to the remote default branch and stops with a clear explanation if so. No force-push or revert is attempted. The user handles it manually.

## Risks

- [RESOLVED] **Auto-merge not enabled on repository:** The `gh pr merge --auto` command will fail if auto-merge is not enabled. → **Decision:** Warn and continue. Treat as non-fatal. The PR is still created successfully. Inform the user how to enable auto-merge in GitHub repository settings.
- [RESOLVED] **Uncommitted changes during branch reset:** The stash/unstash pattern could fail with merge conflicts. → **Decision:** Leave stash and warn. If `git stash pop` fails after branch switch, leave changes in the stash, warn the user, and tell them to run `git stash pop` manually after resolving conflicts. The branch creation and commit relocation still succeed.

## Future Considerations

- [RESOLVED] **Additional git skills:** Future candidates like sync, cleanup, release. → **Decision:** Removed from plan scope. Will be addressed in a future phase if needed.
- [RESOLVED] **Configurable defaults:** Configuration mechanism for merge strategy, branch prefixes, etc. → **Decision:** Removed from plan scope. Will be addressed in a future phase if needed.
