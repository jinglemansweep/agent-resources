# Research

> Source: `.plans/20260226/08-github-ci-action/prompt.md`

## pre-commit/action (GitHub Action)

- **URL:** <https://github.com/pre-commit/action>
- **Status:** Maintenance-only (no new features; maintainers recommend pre-commit.ci for new projects)
- **Latest Version:** v3.0.1 (released 2024-02-07)
- **Compatibility:** Fully compatible — requires `actions/checkout` and `actions/setup-python` as preceding steps, both standard in GitHub Actions workflows. Works with the project's existing `.pre-commit-config.yaml` without modification.
- **Key Findings:**
  - Runs `pre-commit run --all-files` by default, which matches the desired CI behaviour.
  - Supports an `extra_args` input for customising which hooks or files to target.
  - Automatically caches pre-commit environments for faster subsequent runs.
  - The `token` input (for auto-pushing fixes) was removed in v3.0.0 due to security concerns — this is fine since the action is intended as a mandatory check, not an auto-fixer.
- **Concerns:**
  - Maintenance-only status means no new features, but the action is stable and widely used. For a simple "run pre-commit in CI" use case this is adequate.
  - The alternative (pre-commit.ci service) is a separate hosted service with its own integration model — overkill for this project's needs.

## pre-commit (tool)

- **URL:** <https://pre-commit.com/>
- **Status:** Actively maintained
- **Latest Version:** N/A (installed via pip in the action; version managed by the action's cache)
- **Compatibility:** Already in use locally via `.pre-commit-config.yaml`. The CI action installs pre-commit automatically.
- **Key Findings:**
  - The project's `.pre-commit-config.yaml` uses three hook repos: `pre-commit-hooks` (v5.0.0), `markdownlint-cli` (v0.44.0), and `shellcheck-precommit` (v0.10.0).
  - The markdownlint hook excludes `.plans/` — this exclusion applies in CI as well since it reads the same config file.
- **Concerns:** None.
