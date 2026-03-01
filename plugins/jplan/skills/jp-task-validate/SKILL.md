---
name: jp-task-validate
description: Run post-task automated validation checks on created or modified files
allowed-tools: Bash, Read, Glob, Grep
---

# jp-task-validate

Run automated validation checks on files created or modified by a task. This is a standalone, user-invocable skill primarily called by the `jp-execute` orchestrator after each task completes. It detects syntax errors, type issues, failing tests, broken imports, and misplaced files -- then reports results without attempting any fixes.

## Usage

```text
/jp-task-validate <file-paths>
```

**Argument:**

- `<file-paths>` -- One or more file paths (space-separated) that were created or modified by the current task. These are provided by the caller (typically `jp-execute`).

Example:

```text
/jp-task-validate src/auth/handler.py src/auth/models.py tests/test_auth.py
```

## Instructions

### Step 1: Inventory Input Files

Verify that each provided file path exists. For any path that does not exist, record it as an immediate `FAIL` finding with the description "File does not exist".

For each existing file, determine its type by extension:

| Extension | Language / Type |
|---|---|
| `.py` | Python |
| `.js`, `.mjs`, `.cjs` | JavaScript |
| `.ts`, `.mts`, `.cts` | TypeScript |
| `.jsx` | JavaScript (React) |
| `.tsx` | TypeScript (React) |
| `.json` | JSON |
| `.yaml`, `.yml` | YAML |
| `.html` | HTML |
| `.css`, `.scss`, `.less` | CSS |
| `.md` | Markdown |
| `.sh`, `.bash` | Shell script |
| `.toml` | TOML |
| `Dockerfile` | Docker |

If a file does not match any known extension, classify it as `unknown` and skip language-specific checks for it -- only run file structure verification.

### Step 2: Detect Project Tooling

Before running checks, detect which tools and configurations are available in the project. Check for the existence of:

- `pyproject.toml`, `setup.py`, `setup.cfg` -- Python project
- `package.json` -- Node.js project
- `tsconfig.json` -- TypeScript configuration
- `.eslintrc*`, `eslint.config.*` -- ESLint configuration
- `biome.json`, `biome.jsonc` -- Biome configuration
- `.flake8`, `.ruff.toml`, `ruff.toml`, `pyproject.toml` (with `[tool.ruff]`) -- Python linting
- `.mypy.ini`, `mypy.ini`, `pyproject.toml` (with `[tool.mypy]`) -- Python type checking
- `Makefile` -- Make targets
- `.pre-commit-config.yaml` -- Pre-commit hooks

Record which tools are available. Only run checks for which tooling is configured -- do not install or configure tools.

### Step 3: Syntax Validation and Linting

Run syntax and lint checks appropriate to the file types involved. Only run checks for which tools are detected in Step 2.

**Python files:**

1. Syntax check: `python -c "import ast; ast.parse(open('<file>').read())"` for each Python file.
2. If `ruff` is available: `ruff check <files>`.
3. If `flake8` is available and `ruff` is not: `flake8 <files>`.

**JavaScript / TypeScript files:**

1. If `eslint` is available: `npx eslint <files>`.
2. If `biome` is available: `npx biome check <files>`.

**JSON files:**

1. Syntax check: `python -c "import json; json.load(open('<file>'))"` for each JSON file.

**YAML files:**

1. Syntax check: `python -c "import yaml; yaml.safe_load(open('<file>'))"` for each YAML file, or `yamllint <file>` if `yamllint` is available.

**Shell scripts:**

1. If `shellcheck` is available: `shellcheck <files>`.
2. Otherwise: `bash -n <file>` for basic syntax validation.

Record all errors with file path, line number (if available), and error description.

### Step 4: Type Checking

Run type checks only if applicable tooling is configured.

**Python files:**

1. If `mypy` is available: `mypy <files>`.
2. If `pyright` is available: `pyright <files>`.

**TypeScript files:**

1. If `tsconfig.json` exists: `npx tsc --noEmit`.

Record all type errors with file path, line number, and error description.

### Step 5: Unit Tests

Run the project's existing test suite, scoped to tests related to the modified files where possible.

**Python projects:**

1. If `pytest` is available, look for test files that correspond to the modified files (e.g. `src/auth/handler.py` -> `tests/test_handler.py`, `tests/auth/test_handler.py`). If matching test files exist, run: `pytest <matching-test-files> -v`.
2. If no matching test files are found but any of the input files are themselves test files (path contains `test_` or `_test` or is under a `tests/` directory), run: `pytest <test-files> -v`.
3. If no test files are identified, skip this check and note "No related tests found" in the report.

**Node.js projects:**

1. Check `package.json` for a `test` script. If present, run: `npm test` (or the equivalent runner -- `vitest`, `jest`, etc.).
2. If the test runner supports file filtering, scope to related test files where possible.

Record all test failures with test name, file path, and error description.

### Step 6: Import and Dependency Resolution

Check that all imports in the modified files resolve correctly.

**Python files:**

1. For each Python file, run: `python -c "import importlib.util; spec = importlib.util.find_spec('<module>')"` for each top-level import, or more practically, attempt: `python -c "exec(open('<file>').read())"` with appropriate `PYTHONPATH` if the project uses a `src/` layout.
2. Alternatively, if `pyright` or `mypy` was already run in Step 4 and reported import errors, collect those -- do not duplicate the check.

**JavaScript / TypeScript files:**

1. If type checking was run in Step 4 and reported import resolution errors, collect those.
2. Otherwise, check that relative imports point to files that exist on disk.

Record all unresolved imports with file path, line number, and the import that failed to resolve.

### Step 7: File Structure Verification

Verify that the input files are in expected locations based on project conventions:

1. Source files should be under `src/`, `lib/`, or the project root -- not under `tests/`, `docs/`, or `build/` directories (unless they are test or documentation files).
2. Test files should be under `tests/`, `test/`, `__tests__/`, or co-located with source files following the project's existing pattern.
3. Configuration files (`.json`, `.yaml`, `.toml` at the project root) should be at the project root or in a standard config directory.
4. Check for files placed in non-standard locations by comparing against the project's existing directory structure.

Record any files that appear to be in unexpected locations as warnings (not errors).

### Step 8: Generate Validation Report

Compile all findings from Steps 3-7 into a validation report. Determine the overall verdict:

**`PASS`** -- All of the following are true:

- No syntax errors or lint errors.
- No type checking errors.
- All tests pass (or no related tests exist).
- No unresolved imports.
- No missing files from the input list.

**`FAIL`** -- One or more of the following are true:

- Syntax errors or lint errors exist.
- Type checking errors exist.
- Tests fail.
- Imports do not resolve.
- Input files do not exist.

File structure warnings do not affect the verdict -- they are reported but do not cause a `FAIL`.

Output the report in the following format:

```text
Validation Report
=================

Verdict: <PASS | FAIL>

Files checked: <N>

Syntax / Linting:
  <PASS | FAIL (N issues)>
  - <file>:<line> <error description>       (only if FAIL)

Type Checking:
  <PASS | SKIP (not configured) | FAIL (N issues)>
  - <file>:<line> <error description>       (only if FAIL)

Unit Tests:
  <PASS | SKIP (no related tests) | FAIL (N failures)>
  - <test_name> (<file>) <error description>  (only if FAIL)

Import Resolution:
  <PASS | FAIL (N issues)>
  - <file>:<line> <import> not resolved     (only if FAIL)

File Structure:
  <OK | N warnings>
  - <file> <warning description>            (only if warnings)
```

### Step 9: Report

Present the validation report to the caller. If the verdict is `FAIL`, list every issue with its file path, line number (where available), and error description. Do not suggest fixes -- only report what is broken.

If the verdict is `PASS`, confirm that all checks passed and list which checks were run versus skipped.

## Guidelines

- **Report only, never fix.** This skill detects and reports problems. It must not modify any files, auto-fix lint errors, or attempt corrections. Fixes are the responsibility of the implementing agent or `/jp-codereview-fix`.
- **Run only relevant checks.** If no Python files are in the input, do not run Python linters. If no `tsconfig.json` exists, do not attempt TypeScript type checking. Avoid running tools that are not configured for the project.
- **Prefer project-configured tools.** Use the linters, type checkers, and test runners that the project already has configured. Do not impose tools the project does not use.
- **Scope tests where possible.** Running the entire test suite for a single-file change is wasteful. Scope to related tests when the test runner supports it. If scoping is not possible, run the full suite.
- **Line numbers matter.** When reporting issues, always include the file path and line number. If the tool output does not include a line number, report the file path alone -- do not fabricate line numbers.
- **Warnings are not failures.** File structure warnings and style suggestions do not cause a `FAIL` verdict. Only hard errors (syntax, type, test, import) trigger `FAIL`.
