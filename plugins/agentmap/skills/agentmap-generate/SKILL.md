---
name: agentmap-generate
description: Generate or update an .agentmap.yaml codebase orientation map
allowed-tools: Read, Write, Bash, Glob, Grep
---

<!-- tags: agentmap, codemap, orientation, generation -->
<!-- category: codebase-tools -->

# agentmap-generate

Generate or update an `.agentmap.yaml` codebase orientation map for the current repository.

## Usage

```text
/agentmap-generate
```

No arguments required. The skill operates on the repository root detected via `git rev-parse --show-toplevel`.

## Philosophy

An agentmap is a routing table for AI agents -- it tells you where things are, not what they do in detail.

An agentmap is **NOT**:

- Documentation -- it does not explain how things work
- A substitute for reading code -- it tells you which files to read, not what they contain
- A file inventory -- it omits anything an agent can infer from filenames alone

### Token Budget

Keep the agentmap lean. Bloated maps waste context and defeat the purpose.

| Project Size | Target Tokens | Approximate Words |
|---|---|---|
| Small (< 20 files) | 150-300 | 110-220 |
| Medium (20-100 files) | 300-500 | 220-370 |
| Large (100+ files) | 800-1000 | 590-740 |

Use `wc -w .agentmap.yaml` as a rough proxy (1 token ~ 0.75 words for structured YAML).

### Inclusion Criteria

Include entries that help an agent navigate to the right files quickly:

- **Entry points** -- `main.py`, `cli.py`, `index.ts`, `cmd/server/main.go`
- **Config files** -- `pyproject.toml`, `tsconfig.json`, `Cargo.toml`, `.env.example`
- **Public API surfaces** -- route definitions, exported modules, gRPC service files
- **Non-obvious architecture** -- plugin loaders, middleware chains, event buses
- **Key abstractions** -- base classes, trait definitions, core interfaces

### Exclusion Criteria

Omit anything that adds tokens without aiding navigation:

- **Generated files** -- `dist/`, `build/`, `*.min.js`, compiled outputs
- **Vendored dependencies** -- `vendor/`, `node_modules/`, `.venv/`
- **Test fixtures** -- `fixtures/`, `__snapshots__/`, mock data files
- **Boilerplate** -- `__init__.py` (unless it re-exports), `index.js` barrel files with no logic
- **Inferrable from filename** -- do not annotate `README.md` with "project readme" or `LICENSE` with "license file"

## Schema Reference

The agentmap uses YAML with six top-level sections.

```yaml
# ── meta (required) ──────────────────────────────────────────────
meta:
  project: "my-project"          # string, required — project name
  version: 1                     # always 1 — schema version
  updated: "2026-01-15"          # ISO date, required — last update
  stack:                         # list of strings, optional — tech stack
    - python
    - fastapi
    - postgres

# ── tasks (optional) ─────────────────────────────────────────────
# Common shell commands an agent can run immediately.
# All fields optional — omit any that do not apply.
tasks:
  install: "pip install -e '.[dev]'"
  build: "python -m build"
  test: "pytest tests/"
  run: "uvicorn src.main:app --reload"
  lint: "ruff check src/"

# ── tree (required) ──────────────────────────────────────────────
# Annotated directory structure. Use indentation for nesting.
# Terse descriptions after # comments — sentence fragments, no articles.
tree: |
  src/
    main.py            # FastAPI app factory, entry point
    config.py          # Settings via pydantic-settings
    api/
      routes.py        # Route definitions
      deps.py          # Dependency injection helpers
    models/
      user.py          # SQLAlchemy user model
    workers/
      tasks.py         # Celery task definitions
  tests/
  migrations/          # Alembic migration scripts

# ── key_symbols (optional) ───────────────────────────────────────
# Important code entities an agent should know about.
# Format: - path/to/file::SymbolName — description [tags]
#
# Shorthand conventions:
#   .method        — instance method (e.g. Client.connect → .connect)
#   @decorator     — decorator or attribute (e.g. @require_auth)
#   [tag]          — metadata tag (e.g. [entry-point], [config])
key_symbols:
  - src/main.py::create_app — app factory [entry-point]
  - src/api/routes.py::@require_auth — JWT auth decorator
  - src/models/user.py::User — primary user model
  - src/config.py::Settings.from_env — load config from env [config]

# ── conventions (optional) ───────────────────────────────────────
# Project patterns as "- pattern: description" entries.
conventions:
  - routes return Pydantic models: never raw dicts
  - env config via pydantic-settings: no manual os.environ reads
  - alembic for migrations: no raw SQL DDL

# ── sub_maps (optional, experimental) ────────────────────────────
# For monorepos — pointers to nested .agentmap.yaml files.
# NOTE: this section is less battle-tested than core sections.
sub_maps:
  - path: workers/.agentmap.yaml
```

## Generation Process

### Step 1: Reconnaissance

Determine the project shape using language-agnostic commands. Run these from the repository root.

**1a. Detect ecosystem via metadata files:**

Check for the presence of these files to identify the project's language and tooling:

| Ecosystem | Metadata Files |
|---|---|
| Python | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt` |
| Node/JS/TS | `package.json`, `tsconfig.json` |
| Rust | `Cargo.toml` |
| Go | `go.mod` |
| Java | `pom.xml`, `build.gradle`, `build.gradle.kts` |
| C# | `*.sln`, `*.csproj` |
| Ruby | `Gemfile`, `*.gemspec` |
| Elixir | `mix.exs` |
| C/C++ | `CMakeLists.txt`, `Makefile`, `meson.build` |
| Generic Make | `Makefile` |

Commands:

```bash
# Check for ecosystem metadata files
ls pyproject.toml setup.py setup.cfg requirements.txt \
   package.json tsconfig.json \
   Cargo.toml go.mod \
   pom.xml build.gradle build.gradle.kts \
   mix.exs Gemfile CMakeLists.txt Makefile meson.build \
   2>/dev/null

# Check for .sln and .csproj (glob patterns)
ls *.sln *.csproj *.gemspec 2>/dev/null
```

**1b. Read detected metadata files:**

```bash
# Read the first 30 lines of each detected metadata file
head -30 <detected-file>
```

Extract project name, dependencies, build/test/run commands, and entry points from these files.

**1c. Survey the file tree:**

```bash
# Shallow directory listing (2 levels deep)
find . -maxdepth 2 -type f -not -path './.git/*' -not -path './node_modules/*' \
  -not -path './.venv/*' -not -path './vendor/*' -not -path './dist/*' \
  -not -path './build/*' -not -path './__pycache__/*' | head -80

# Top-level directories only
ls -d */ 2>/dev/null
```

**1d. Generic heuristics (fallback when no metadata file detected):**

- Identify standard source directories: `src/`, `lib/`, `cmd/`, `app/`, `pkg/`, `internal/`
- Look for entry point filenames: `main`, `cli`, `app`, `index`, `server` in any language extension
- Scan `README.md` for architecture clues:

```bash
head -60 README.md 2>/dev/null
```

### Step 2: Identify What Matters

Apply the inclusion and exclusion criteria from the Philosophy section above.

For each file or directory discovered in Step 1, decide:

1. **Include** -- an agent would waste time without knowing this exists
2. **Exclude** -- an agent can find this on its own or does not need it
3. **Annotate** -- include with a terse description because the name alone is ambiguous

When in doubt, exclude. A smaller map that covers the important parts is better than a comprehensive map that wastes tokens.

### Step 3: Write

Follow telegraphic style rules:

- **Sentence fragments, not prose** -- "JWT auth decorator" not "This is a decorator that handles JWT authentication"
- **No articles** -- omit "a", "an", "the"
- **No filler words** -- omit "various", "responsible for", "used to"
- **Descriptions under 8 words** -- if it takes more, the entry is too detailed
- **Use the schema structure exactly** -- `meta`, `tasks`, `tree`, `key_symbols`, `conventions`, `sub_maps`

Populate each section:

1. **meta** -- project name, today's date, detected stack
2. **tasks** -- extract install/build/test/run/lint commands from metadata files; omit fields that do not apply
3. **tree** -- annotated directory structure covering included items only
4. **key_symbols** -- list important code entities found during reconnaissance; use `.method`, `@decorator`, and `[tag]` shorthand
5. **conventions** -- note patterns visible in the code (naming, architecture, error handling)
6. **sub_maps** -- only for monorepos with distinct sub-packages; omit entirely for single-package repos

### Step 4: Validate

Run three checks before saving:

**4a. Cold-start test:** Imagine reading the agentmap with zero prior context about this project. Can you identify:

- What the project does (from `meta.stack` and `tree`)?
- How to run it (from `tasks`)?
- Where to start reading code (from `tree` annotations and `key_symbols`)?

If any answer is "no", add the missing information.

**4b. Token count check:**

```bash
wc -w .agentmap.yaml
```

Compare word count against the target range for the project size (see Token Budget table). If over budget, trim the lowest-value entries -- start with `conventions`, then `key_symbols`, then `tree` annotations.

**4c. Redundancy check:** Review every `tree` annotation and `key_symbols` entry. If the description repeats what the filename already conveys, remove it. Examples of redundant entries:

- `README.md  # project readme` -- the filename says this
- `tests/     # test directory` -- obvious from the name
- `src/models/user.py::User — user model` -- the path already says this

### Step 5: Save

Write the validated agentmap to `.agentmap.yaml` in the repository root.

```bash
# The file is always saved at the repo root
git rev-parse --show-toplevel
# Write to <repo-root>/.agentmap.yaml
```

For monorepos with distinct sub-packages, also consider creating nested `.agentmap.yaml` files in each package directory and referencing them via `sub_maps` in the root file.

## Update Process

### When to Update

Update the agentmap after:

- **Structural changes** -- new modules, directories, or entry points added or removed
- **Convention changes** -- project patterns or architecture decisions that shifted
- **Periodic maintenance** -- if weeks have passed since the last update

Do **NOT** update after:

- Every commit or minor edit
- Changes to file contents that do not affect structure
- Test additions or fixture changes

### Detecting What Changed

Use git to identify structural changes since the last agentmap update:

```bash
# Files changed since the agentmap was last updated
git diff --stat $(git log -1 --format=%ai .agentmap.yaml | cut -d' ' -f1)..HEAD --name-only
```

Focus on changes that affect the `tree` or `key_symbols` sections: new files, renamed files, deleted files, new directories.

### Staleness Detection

Compare the `updated` field in the existing `.agentmap.yaml` against recent git activity:

```bash
# Last agentmap update date
head -5 .agentmap.yaml | grep updated

# Most recent commit date
git log -1 --format=%ai
```

If the gap is significant and structural changes have occurred, the map is stale.

### Merge, Do Not Regenerate

When updating an existing agentmap:

1. **Read the existing file first** -- preserve human-curated descriptions and carefully worded annotations
2. **Merge changes** -- add new entries, update changed entries, flag potentially stale entries
3. **Flag rather than delete** -- if a file or symbol no longer exists, add a `# STALE?` comment rather than removing it outright; the human curator may have context you lack
4. **Update the `meta.updated` date** to today

Never regenerate from scratch unless the user explicitly requests it. Curated descriptions are valuable and costly to recreate.

## Guidelines

- **Lean over complete.** A 300-word agentmap that covers the important parts outperforms a 1500-word map that covers everything.
- **The agentmap is a starting point, not a reference manual.** It should point agents to the right files; reading those files provides the detail.
- **Respect existing content.** During updates, treat the current agentmap as curated work. Change only what needs changing.
- **Language-agnostic by default.** The reconnaissance step covers many ecosystems. Do not assume any particular language unless metadata files confirm it.
- **When in doubt, exclude.** Every entry costs tokens. Justify each entry's presence by asking: "Would an agent waste meaningful time without this?"
