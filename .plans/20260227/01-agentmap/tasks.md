# Task List

> Source: `.plans/20260227/01-agentmap/plan.md`

## Plugin Scaffolding

### Directory and Metadata

- [x] **Create `plugins/agentmap/plugin.json`** — Create the plugin metadata file following the pattern in `plugins/jinglemansweep/plugin.json`. Contents: `name` set to `"agentmap"`, `version` set to `"0.1.0"`, `description` set to `"AI-powered codebase orientation maps"`, `skills` array containing `["agentmap-read", "agentmap-generate"]`, `agents` as an empty array `[]`, `commands` as an empty array `[]`. Verify the file is valid JSON.

- [x] **Create `plugins/agentmap/install.sh`** — Create the installation script following the pattern in `plugins/jinglemansweep/install.sh`. The script should: declare `DEST="${CLAUDE_DIR:-$HOME/.claude}"`, copy `skills/*` to `"${DEST}/skills/"`, copy `example.agentmap.yaml` and `README.md` to `"${DEST}/agentmap/"` (so users have the reference files available locally), and echo a confirmation message. Use `#!/usr/bin/env bash` shebang. Make the file executable. Note: no agents directory to copy since this plugin has no agents.

- [x] **Create skill directory structure** — Create the empty directories `plugins/agentmap/skills/agentmap-read/` and `plugins/agentmap/skills/agentmap-generate/`. These will hold the SKILL.md files created in subsequent groups.

## Agentmap Generate Skill

### SKILL.md File

- [x] **Create `plugins/agentmap/skills/agentmap-generate/SKILL.md`** — Create the full generation/update skill file. This is the most complex deliverable. The file must contain all four major subsections described below, structured as a single markdown document that an agent can follow step-by-step. Add structured metadata comments at the top of the file for future skill auto-discovery (e.g. `<!-- tags: agentmap, codemap, orientation, generation -->` and `<!-- category: codebase-tools -->`). The skill should be invocable (user-facing) with usage syntax `/agentmap-generate`. The subsections are:
  - [x] **Philosophy section** — Define what an agentmap is: "a routing table for AI agents — it tells you where things are, not what they do in detail." State that it is NOT documentation, NOT a substitute for reading code. Include token budget guidance: 300–500 tokens for medium projects, 800–1000 for large. Provide concrete inclusion criteria (entry points, config files, public API surfaces, non-obvious architecture, key abstractions) and exclusion criteria (generated files, vendored dependencies, test fixtures, boilerplate, anything an agent can infer from filenames). Give examples of each.
  - [x] **Schema reference section** — Full YAML schema with inline comments covering all six sections. `meta` (required): fields `project` (string, required), `version` (always `1`), `updated` (ISO date, required), `stack` (list of strings, optional). `tasks` (optional): fields `install`, `build`, `test`, `run`, `lint` — all optional strings containing shell commands. `tree` (required): annotated directory structure using indentation, with terse descriptions after `#` comments. `key_symbols` (optional): list of important code entities with format `- path/to/file::SymbolName — description [tags]`; document shorthand conventions: `.method` for instance methods, `@decorator` for decorators/attributes, `[tag]` for metadata tags. `conventions` (optional): list of project patterns as `- pattern: description` entries. `sub_maps` (optional, experimental): for monorepos, list of `- path: relative/path` entries pointing to nested `.agentmap.yaml` files; include a note that this section is less battle-tested than core sections.
  - [x] **Generation process section** — Five numbered steps. **Step 1 — Reconnaissance**: language-agnostic commands to understand project shape. Must explicitly cover detection for these ecosystems via metadata file presence: Python (`pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`), Node/JS/TS (`package.json`, `tsconfig.json`), Rust (`Cargo.toml`), Go (`go.mod`), Java (`pom.xml`, `build.gradle`, `build.gradle.kts`), C# (`*.sln`, `*.csproj`), Ruby (`Gemfile`, `*.gemspec`), Elixir (`mix.exs`), C/C++ (`CMakeLists.txt`, `Makefile`, `meson.build`), generic Make (`Makefile`). Include generic file tree heuristics as fallback: scan top-level directory, identify `src/`, `lib/`, `cmd/`, `app/`, `pkg/` patterns, look for `main`, `cli`, `app`, `index`, `server` in filenames for entry points, scan README for architecture clues. Provide actual commands using `ls`, `find` (shallow depth), `head` for metadata files. **Step 2 — Identify what matters**: apply inclusion/exclusion criteria from philosophy section. **Step 3 — Write**: telegraphic style rules — sentence fragments not prose, no articles, no filler words, descriptions under 8 words. **Step 4 — Validate**: cold-start test (imagine reading this with zero context — can you navigate?), token count check (`wc -w` as proxy, target word counts matching token budgets), redundancy check (does any entry duplicate what the filename already says?). **Step 5 — Save**: write to `.agentmap.yaml` in repo root, note monorepo sub_maps guidance for multi-package repos.
  - [x] **Update process section** — Cover: when to update (after structural changes like new modules/directories, convention changes, periodic maintenance — NOT after every commit or minor edits). Git-based change detection: `git diff --stat $(git log -1 --format=%ai .agentmap.yaml | cut -d' ' -f1)..HEAD --name-only` to see what changed since last update. Preserve human-curated descriptions: read existing file first, merge changes rather than regenerating from scratch, flag entries that may be stale rather than deleting them. Staleness detection: compare `updated` field against recent git activity.

## Agentmap Read Skill

### SKILL.md File

- [ ] **Create `plugins/agentmap/skills/agentmap-read/SKILL.md`** — Create the lightweight consumption skill. Hard cap of 250 tokens (~40 lines). This skill is always-loaded so token economy is critical. Add structured metadata comments at the top (e.g. `<!-- tags: agentmap, codemap, orientation, reading -->` and `<!-- category: codebase-tools -->`). Must NOT be user-invocable (no slash command — it's auto-loaded context). The content must cover: (1) one-line purpose statement ("`.agentmap.yaml` is a codebase routing table — read it before starting any task"), (2) one-line description of each of the six schema sections (`meta` — project identity and stack; `tasks` — common shell commands; `tree` — annotated directory layout; `key_symbols` — important code entities; `conventions` — project patterns and rules; `sub_maps` — monorepo delegation), (3) staleness warning ("check the `updated` field against recent git activity"), (4) routing-table caveat ("this is an index, not a substitute for reading code — always verify by reading the actual files"), (5) version note ("this skill covers v1; check the `version` field"). Iterate and trim until the file is under 250 tokens. Verify with `wc -w` as a rough proxy (aim for under 190 words).

## Example Agentmap

### Reference File

- [ ] **Create `plugins/agentmap/example.agentmap.yaml`** — Create a complete, realistic example demonstrating all schema sections. Base it on a fictional but realistic medium-complexity project: a Flask/FastAPI web application called "taskflow" with CLI tooling, REST API, background workers, and a PostgreSQL database. The file must: set `version: 1`, include an `updated` date, list a realistic `stack` (e.g. `[python, fastapi, sqlalchemy, celery, postgres]`). `tasks` section: include `install`, `test`, `run`, and `lint` commands (omit `build` to demonstrate optional field absence). `tree` section: show an annotated directory tree with terse descriptions (~15-20 entries covering `src/`, `tests/`, `migrations/`, `config/`, etc.). `key_symbols` section: list 6-8 important symbols demonstrating `.method` shorthand (e.g. `src/api/auth.py::.verify_token`), `@decorator` notation (e.g. `src/api/routes.py::@require_auth`), and `[tags]` metadata (e.g. `[entry-point]`, `[config]`). `conventions` section: 3-4 project patterns (e.g. "routes return Pydantic models", "background tasks use Celery"). `sub_maps` section: include one entry pointing to a hypothetical `workers/` sub-package, with a YAML comment noting this section is experimental. Validate that the file is parseable as valid YAML. The overall token count should be in the 300-500 range (medium project).

## Documentation

### Plugin README

- [ ] **Create `plugins/agentmap/README.md`** — Create a concise, human-facing README targeting developers already familiar with Claude Code. Structure: (1) Title and one-paragraph description of what agentmap is. (2) "Installation" section: explain that `install.sh` copies skills to `~/.claude/skills/`; show the command `cd plugins/agentmap && bash install.sh`; mention `CLAUDE_DIR` override. (3) "Usage" section: explain the two-skill model — `agentmap-read` is automatically loaded to teach agents how to consume maps, `agentmap-generate` is invoked on demand via `/agentmap-generate` to create or update maps. (4) "CLAUDE.md Setup" section: include the suggested snippet verbatim in a fenced code block: `If .agentmap.yaml exists in the repo root, use the agentmap-read skill before starting any task.` and `To create or update an agentmap, use the agentmap-generate skill.` (5) "Example" section: reference the `example.agentmap.yaml` file with a brief note that it demonstrates all schema sections. No marketing filler, no badges.

### Repo Integration

- [ ] **Update `marketplace.json`** — Add a new entry to the `plugins` array in `marketplace.json` (at repo root). The new entry: `{ "name": "agentmap", "description": "AI-powered codebase orientation maps", "path": "plugins/agentmap" }`. Verify the file remains valid JSON after editing.

- [ ] **Update repo `README.md`** — Modify the root `README.md` to include the agentmap plugin. Two changes required: (1) In the "Directory Structure" code block, add the `agentmap/` tree under `plugins/` showing `plugin.json`, `install.sh`, `README.md`, `example.agentmap.yaml`, and `skills/` with both skill directories each containing `SKILL.md`. (2) In the "Plugins" section, add a new `### agentmap` subsection after the `jinglemansweep` subsection. Include: description ("AI-powered codebase orientation maps"), version ("0.1.0"), skills list with one-line descriptions for `agentmap-read` and `agentmap-generate`. Also update the introductory sentence from "Currently hosts the `jinglemansweep` plugin" to "Currently hosts the `jinglemansweep` and `agentmap` plugins" (both in the README and check if CLAUDE.md needs a similar update).

## Validation

### Verify All Deliverables

- [ ] **Validate `example.agentmap.yaml` is valid YAML** — Parse the example file using a YAML parser (e.g. `python3 -c "import yaml; yaml.safe_load(open('plugins/agentmap/example.agentmap.yaml'))"` or the pre-commit `check-yaml` hook). Fix any syntax errors found.

- [ ] **Validate read skill token budget** — Run `wc -w plugins/agentmap/skills/agentmap-read/SKILL.md` and verify the word count is under 190 words (rough proxy for 250 tokens). If over budget, trim until it fits. The 250-token cap is a hard requirement.

- [ ] **Validate language-agnosticism** — Search both SKILL.md files for hardcoded language-specific assumptions that aren't clearly framed as examples. Commands like `grep -i "python\|javascript\|typescript\|rust\|go\|java" plugins/agentmap/skills/*/SKILL.md` — any hits should be in example/detection contexts only, not as assumptions about the target project.

- [ ] **Validate schema consistency** — Manually compare the schema reference in `agentmap-generate/SKILL.md` against the structure of `example.agentmap.yaml`. Every section and field used in the example must be documented in the schema. Every required field in the schema must appear in the example.

- [ ] **Validate CLAUDE.md snippet** — Verify the CLAUDE.md snippet in `plugins/agentmap/README.md` references the correct skill names (`agentmap-read` and `agentmap-generate`). Verify it matches the skill names in `plugin.json`.

- [ ] **Run pre-commit hooks** — Run `pre-commit run --all-files` to verify all new and modified files pass the repository's pre-commit checks (JSON validation, YAML validation, markdown linting, trailing whitespace, end-of-file newlines, shellcheck on `install.sh`). Fix any failures.
