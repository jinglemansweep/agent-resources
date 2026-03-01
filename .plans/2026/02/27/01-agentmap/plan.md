# Implementation Plan

> Source: `.plans/20260227/01-agentmap/prompt.md`

## Overview

Build a new `agentmap` plugin containing two Claude Code skills (`agentmap-read` and `agentmap-generate`) that enable AI agents to create and consume `.agentmap.yaml` codebase orientation maps. The plugin is self-contained, language-agnostic, and has zero runtime dependencies — all deliverables are pure markdown and YAML.

## Architecture & Approach

The agentmap concept is a lightweight routing table for AI agents: a single YAML file that tells an agent where things are and how a project is structured, without duplicating documentation. Two skills divide the workflow — `agentmap-read` is always-loaded and teaches agents how to consume an existing map, while `agentmap-generate` is loaded on demand and provides the full process for creating or updating one.

The deliverables live in this repo as a new plugin (`plugins/agentmap/`) following the existing plugin conventions. The agentmap skills deliberately omit the `jms-` prefix since they're designed as a reusable, project-agnostic toolkit — not tied to the jinglemansweep planning workflow. The plugin includes its own `plugin.json`, `install.sh`, and README, making it independently installable.

The YAML schema uses `version: 1` to allow future evolution. The schema covers six sections: `meta` (project identity), `tasks` (common commands), `tree` (annotated directory structure), `key_symbols` (important code entities), `conventions` (project patterns), and `sub_maps` (monorepo delegation). All sections except `meta` and `tree` are optional.

## Components

### Agentmap Read Skill

**Purpose:** Teach agents how to consume an existing `.agentmap.yaml` file. This is the always-loaded skill — it must be small enough to include in every conversation context.

**Inputs:** The agent's context window (loaded automatically or via CLAUDE.md directive).

**Outputs:** Agent understands how to find, read, and use each section of an agentmap.

**Notes:** Hard cap of 250 tokens (~40 lines) — strictly enforced, iterate until it fits. Must cover all six schema sections in one-line descriptions. Must warn about staleness checking and that the agentmap is a routing aid, not a substitute for reading code. Include a one-line version note: "This skill covers v1; check the `version` field." Add structured metadata comments (tags/categories) as forward-compatible hints for potential future skill auto-discovery. No language-specific assumptions.

### Agentmap Generate Skill

**Purpose:** Provide a complete, step-by-step process for creating or updating an `.agentmap.yaml` file for any codebase. Loaded on demand when a user invokes the skill.

**Inputs:** The agent reads the target codebase using its built-in tools (bash, file reading, glob, grep).

**Outputs:** A valid `.agentmap.yaml` file in the repository root.

**Notes:** This is the most complex component. It has four major subsections:

- *Philosophy* — defines what an agentmap is (routing table, not docs), token budget guidance (300–500 tokens medium, 800–1000 large), and inclusion/exclusion criteria with examples.
- *Schema reference* — full YAML schema with inline comments, all sections documented, required vs optional clearly marked, shorthand conventions (`.method`, `@decorator`, `[tags]`).
- *Generation process* — five steps: (1) Reconnaissance using language-agnostic commands covering all major ecosystems (detect project metadata files, scan file tree, find entry points), (2) Identify what matters using inclusion/exclusion criteria, (3) Write using telegraphic style, (4) Validate with cold-start test and token check, (5) Save with monorepo sub_maps guidance.
- *Update process* — when to update, git-based change detection, preserving human curation, staleness detection.

The reconnaissance step is the most critical for language-agnosticism. It must explicitly cover the top ~10 ecosystems (Python, Node, Rust, Go, Java, C#, Ruby, Elixir, C/C++, generic Make) with specific detection commands for each, plus generic file tree heuristics as fallback for unknown ecosystems. Detection is via metadata file presence (`pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Makefile`, `CMakeLists.txt`, `*.sln`, `mix.exs`, `Gemfile`, etc.). Add structured metadata comments (tags/categories) to this SKILL.md as forward-compatible hints for potential future skill auto-discovery.

### Example Agentmap

**Purpose:** A complete, realistic `.agentmap.yaml` demonstrating all schema sections at the intended level of detail. Serves as a reference for both agents and humans.

**Inputs:** None — this is a static reference file based on a plausible medium-complexity project.

**Outputs:** A valid, parseable YAML file.

**Notes:** Should demonstrate terse descriptions, `[tags]` metadata, `.method` shorthand, `@decorator` notation, and selective omission of optional fields. Based on a fictional but realistic project (e.g. a Flask/FastAPI web application with CLI tooling) — specific enough to be realistic, generic enough that the format choices are clearly transferable. The `sub_maps` section should be included but marked as experimental with a note that it's less battle-tested than the core sections.

### README

**Purpose:** Human-facing documentation explaining what agentmap is, how to install it, and how to use it.

**Inputs:** None.

**Outputs:** A concise markdown file targeting developers already familiar with Claude Code.

**Notes:** Must include the suggested CLAUDE.md snippet verbatim. Installation is copying skill directories into `.claude/skills/`. Covers the two-skill model (read = automatic, generate = on-demand). Should reference or embed the example. No marketing filler.

### Plugin Scaffolding

**Purpose:** Integrate the agentmap deliverables into this repo's plugin structure so they can be installed via `install.sh` and discovered via `marketplace.json`.

**Inputs:** Existing plugin conventions from the `jinglemansweep` plugin.

**Outputs:** `plugin.json`, `install.sh`, updated `marketplace.json`, updated repo `README.md`.

**Notes:** Follows the same pattern as the existing `jinglemansweep` plugin. The agentmap plugin has no agents, only two skills. The `install.sh` copies skills to `~/.claude/skills/` and the example and README to an appropriate location. The repo-level `README.md` gains a new plugin section.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `plugins/agentmap/plugin.json` | Create | Plugin metadata (name, version, skills list) |
| `plugins/agentmap/install.sh` | Create | Installation script copying skills to `~/.claude/skills/` |
| `plugins/agentmap/README.md` | Create | Human-facing documentation with install instructions and CLAUDE.md snippet |
| `plugins/agentmap/skills/agentmap-read/SKILL.md` | Create | Lightweight consumption skill (<250 tokens) |
| `plugins/agentmap/skills/agentmap-generate/SKILL.md` | Create | Full generation/update skill with schema reference and process |
| `plugins/agentmap/example.agentmap.yaml` | Create | Reference example covering all schema sections |
| `marketplace.json` | Modify | Add agentmap plugin entry |
| `README.md` | Modify | Add agentmap plugin section to directory tree and plugin list |
