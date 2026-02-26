# Task List

> Source: `.plans/20260226/07-pre-commit-hooks/plan.md`

## Configuration

### Markdownlint Configuration

- [x] **Create `.markdownlint.yaml`** — Create the file `.markdownlint.yaml` at the repository root with the following content. Disable these rules: `MD013` (line-length — existing files have long prose lines), `MD033` (no-inline-html — template files use HTML comments), `MD041` (first-line-heading — SKILL.md files start with YAML front matter), `MD024` (no-duplicate-heading — skill files reuse heading names like "Step 1", "Step 2"). Add an `ignores` key with the glob pattern `.plans/**` to exclude the `.plans/` directory from linting. Verify by confirming the file is valid YAML.

### Pre-Commit Configuration

- [x] **Create `.pre-commit-config.yaml`** — Create the file `.pre-commit-config.yaml` at the repository root. Define three repos:
  - [x] **Add pre-commit-hooks repo** — Add repo `https://github.com/pre-commit/pre-commit-hooks` at rev `v5.0.0` with hooks: `check-json`, `check-yaml`, `trailing-whitespace`, `end-of-file-fixer`, `check-merge-conflict`, `check-added-large-files`, `detect-private-key`.
  - [x] **Add markdownlint-cli repo** — Add repo `https://github.com/igorshubovych/markdownlint-cli` at rev `v0.44.0` with hook: `markdownlint`.
  - [x] **Add shellcheck-precommit repo** — Add repo `https://github.com/koalaman/shellcheck-precommit` at rev `v0.10.0` with hook: `shellcheck`.

## Validation

- [ ] **Run pre-commit against all files** — Execute `pre-commit run --all-files` from the repository root. Review the output for each hook. The `trailing-whitespace` and `end-of-file-fixer` hooks may auto-fix existing files on first run — this is expected. If markdownlint or shellcheck report errors, investigate whether they are legitimate issues or require config adjustments. Stage and include any auto-fixes.

## Documentation

- [ ] **Update `README.md` with pre-commit setup** — Add a section to `README.md` documenting the pre-commit configuration. Include: what the pre-commit hooks enforce (JSON/YAML validation, Markdown linting, shell linting, whitespace/EOF fixes, merge conflict detection, large file prevention, private key detection), how to install (`pip install pre-commit && pre-commit install`), how to run manually (`pre-commit run --all-files`), and a note about the `.markdownlint.yaml` config customizations.
