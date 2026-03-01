# Research

> Source: `.plans/20260226/07-pre-commit-hooks/prompt.md`

## pre-commit

- **URL:** <https://pre-commit.com/>
- **Status:** Actively maintained
- **Latest Version:** 4.5.1
- **Compatibility:** Python-based CLI; language-agnostic for hook execution. Works with any git repository.
- **Key Findings:**
  - Install via `pip install pre-commit`
  - Config file: `.pre-commit-config.yaml` at repo root
  - `pre-commit install` sets up the git hook; `pre-commit run --all-files` for manual/CI runs
  - Supports monorepo workflows (v4.5.0+)
- **Concerns:** None. Well-established tool with broad adoption.

## pre-commit/pre-commit-hooks

- **URL:** <https://github.com/pre-commit/pre-commit-hooks>
- **Status:** Actively maintained
- **Latest Version:** v5.0.0
- **Compatibility:** Fully compatible; no project-specific constraints.
- **Key Findings:**
  - Provides all required general hooks: `check-json`, `check-yaml`, `trailing-whitespace`, `end-of-file-fixer`, `check-merge-conflict`, `check-added-large-files`
  - Also offers `check-symlinks`, `detect-private-key`, and others that may be useful
- **Concerns:** None.

## markdownlint-cli (igorshubovych/markdownlint-cli)

- **URL:** <https://github.com/igorshubovych/markdownlint-cli>
- **Status:** Actively maintained
- **Latest Version:** v0.44.0
- **Compatibility:** Node.js-based; pre-commit handles the runtime automatically.
- **Key Findings:**
  - Native pre-commit support with hook id `markdownlint`
  - Config via `.markdownlint.yaml` or `.markdownlint-cli2.yaml`
  - Existing repo files have long lines (>120 chars) and use HTML comments in templates — rules MD013 (line-length) and MD033 (no-inline-html) will need disabling
  - SKILL.md files use YAML front matter — rule MD041 (first-line-heading) may fire on these; needs suppression
- **Concerns:** Need a `.markdownlint.yaml` config to avoid false positives on existing files.

## shellcheck-precommit (koalaman/shellcheck-precommit)

- **URL:** <https://github.com/koalaman/shellcheck-precommit>
- **Status:** Actively maintained (official ShellCheck pre-commit integration)
- **Latest Version:** v0.10.0
- **Compatibility:** Separate repo from main ShellCheck to decouple release cycles. Fully compatible.
- **Key Findings:**
  - Hook id: `shellcheck`
  - Only one shell script in this repo (`install.sh`), but still valuable for catching issues
- **Concerns:** None.
