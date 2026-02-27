# Agentmap Skill — Implementation Plan

## Overview

Build a reusable Claude Code skill pair (`agentmap-read` and `agentmap-generate`) that can be dropped into any project to enable AI agents to create and consume `.agentmap.yaml` codebase orientation maps. Language-agnostic — must work for Python, TypeScript, Go, Rust, Java, mixed-language projects, etc.

## Deliverables

A directory structure ready to be copied into a project's `.claude/skills/` (or equivalent skill location):

```
agentmap/
├── README.md                     # Human-facing docs: what this is, how to use it
├── agentmap-read/
│   └── SKILL.md                  # Consumption skill (lightweight, always loaded)
├── agentmap-generate/
│   └── SKILL.md                  # Generation/update skill (loaded on demand)
└── example.agentmap.yaml         # Reference example for agents and humans
```

Plus a suggested CLAUDE.md snippet the user can paste into their project.

## Design Constraints

- **Language-agnostic**: The skills must not assume any specific language, framework, or toolchain. Reconnaissance commands in the generate skill should cover common ecosystems and gracefully handle unknown ones.
- **No runtime dependencies**: Pure skill files (markdown). No Python scripts, no npm packages, no binaries. The agent does all the work using its own capabilities (bash, file reading, etc.).
- **Minimal token footprint**: The read skill should be under 250 tokens. The generate skill can be longer since it's loaded on demand.
- **Schema version 1**: Include a `version: 1` field in the agentmap spec to allow future evolution without breaking existing files.

---

## Task 1: Agentmap Read Skill

**File**: `agentmap-read/SKILL.md`

### Requirements

- Explain the purpose of an agentmap in one line
- List each section of an agentmap (`meta`, `tasks`, `tree`, `key_symbols`, `conventions`, `sub_maps`) with a one-line explanation of how to use it
- Instruct the agent to read `.agentmap.yaml` before starting any task
- Warn that the agentmap is a routing table, not a substitute for reading code
- Mention staleness: check the `updated` field against recent git activity
- Keep the entire file under 250 tokens (roughly 40 lines)

### Acceptance Criteria

- An agent with zero prior context can read this skill and immediately understand how to use an agentmap
- No unnecessary prose or repetition
- No language-specific assumptions

---

## Task 2: Agentmap Generate Skill

**File**: `agentmap-generate/SKILL.md`

### Requirements

#### 2a: Philosophy section
- Define what an agentmap is and isn't (routing table, not documentation)
- Token budget guidance: 300-500 tokens for medium projects, 800-1000 for large
- What to include vs exclude (with concrete examples)

#### 2b: Schema reference
- Full YAML schema with inline comments
- All sections: `meta`, `tasks`, `tree`, `key_symbols`, `conventions`, `sub_maps`
- All fields in `tasks` are optional (install, build, test, run, lint)
- Clearly mark which sections are required vs optional
- Shorthand conventions: `.method` for instance methods, `@name` for decorators, `[tags]` for metadata

#### 2c: Generation process (language-agnostic)
- **Step 1 — Reconnaissance**: Commands to understand project shape. Must cover multiple ecosystems:
  - File tree exploration (generic `find` commands, not language-specific)
  - Project metadata detection: check for `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Makefile`, `CMakeLists.txt`, `*.sln`, `mix.exs`, `Gemfile`, etc.
  - README scanning
  - Entry point identification heuristics (look for `main`, `cli`, `app`, `index`, `server` in filenames)
- **Step 2 — Identify what matters**: Criteria for including/excluding files and symbols (these are already language-agnostic in our drafts)
- **Step 3 — Write**: Formatting rules, telegraphic descriptions, redundancy avoidance
- **Step 4 — Validate**: Cold start test, token budget check, staleness risk, redundancy check
- **Step 5 — Save**: Where to put it, monorepo considerations with `sub_maps`

#### 2d: Update process
- When to update (structural changes, convention changes, periodic maintenance — NOT every commit)
- Git-based change detection since last `updated` date
- Preserve human-curated descriptions during updates
- Staleness detection commands

### Acceptance Criteria

- An agent can follow this skill to generate an agentmap for a codebase in any language
- The reconnaissance step doesn't fail or produce nonsensical output for uncommon project structures
- The schema is unambiguous — two agents generating from the same codebase should produce structurally similar results
- Update process preserves prior curation rather than regenerating from scratch

---

## Task 3: Example Agentmap

**File**: `example.agentmap.yaml`

### Requirements

- A complete, realistic example covering all sections of the schema
- Based on a plausible medium-complexity project (the melabasco example works well)
- Comments explaining non-obvious format choices
- Demonstrates: terse descriptions, `[tags]`, `.method` shorthand, `@decorator` notation, optional fields being absent where appropriate

### Acceptance Criteria

- Serves as a valid reference for both agents and humans
- Parseable as valid YAML
- Demonstrates the intended level of detail (not too sparse, not too verbose)

---

## Task 4: README

**File**: `README.md`

### Requirements

- Brief human-facing explanation of what agentmap is
- How to install (copy skill files to your project)
- How it works (two skills: read is automatic, generate is on-demand)
- Suggested CLAUDE.md snippet:
  ```markdown
  If `.agentmap.yaml` exists in the repo root, use the agentmap-read skill before starting any task.
  To create or update an agentmap, use the agentmap-generate skill.
  ```
- Link to or embed the example
- Keep it concise — this is a tool for developers who already use Claude Code

### Acceptance Criteria

- A developer can go from "what is this" to "it's working in my project" in under 2 minutes
- No unnecessary marketing or filler

---

## Task 5: Validation

After all files are created:

1. Verify `example.agentmap.yaml` is valid YAML (parse it)
2. Verify the read skill is under 250 tokens (estimate)
3. Verify no language-specific assumptions leak into either skill (search for hardcoded references to specific languages that aren't used as examples)
4. Verify the schema in the generate skill matches the example file structure
5. Verify the CLAUDE.md snippet references the correct skill names

---

## Notes for the Implementing Agent

- The draft skill files from our design session are available as reference but should be refined during implementation, particularly the reconnaissance section which needs broader language coverage.
- Prioritise clarity and conciseness. If a sentence can be cut without losing information, cut it.
- The generate skill is the most complex piece. Spend the most time getting the reconnaissance step and schema reference right.
- Test the example YAML by mentally walking through "I'm an agent, I just loaded this, now the user asks me to add a feature" — does the agentmap route you to the right files?