# Product Requirements Document

> Source: `.plans/2026/03/01/07-tidying/prompt.md`

## Project Overview

This phase removes two unused components from the agent-resources toolkit and updates all documentation to reflect the removals. The `jms-git-push` skill and `jp-planner` agent are no longer used in practice and should be cleanly deleted along with all references across plugin metadata, README, and install scripts.

## Goals

- Eliminate dead code by removing the unused `jms-git-push` skill and `jp-planner` agent
- Ensure all documentation and metadata accurately reflects the current inventory of skills and agents
- Leave the repository in a clean, consistent state with no dangling references

## Functional Requirements

### REQ-001: Remove jms-git-push Skill

**Description:** Delete the `plugins/jinglemansweep/skills/jms-git-push/` directory and all its contents.

**Acceptance Criteria:**

- [ ] The directory `plugins/jinglemansweep/skills/jms-git-push/` no longer exists
- [ ] No files remain from the deleted skill

### REQ-002: Remove jms-git-push from Plugin Metadata

**Description:** Remove the `"jms-git-push"` entry from the `skills` array in `plugins/jinglemansweep/plugin.json`.

**Acceptance Criteria:**

- [ ] `plugins/jinglemansweep/plugin.json` does not contain `"jms-git-push"` in its `skills` array
- [ ] The JSON file remains valid after the edit

### REQ-003: Remove jp-planner Agent

**Description:** Delete the `plugins/jplan/agents/jp-planner.md` file.

**Acceptance Criteria:**

- [ ] The file `plugins/jplan/agents/jp-planner.md` no longer exists

### REQ-004: Remove jp-planner from Plugin Metadata

**Description:** Remove the `"jp-planner"` entry from the `agents` array in `plugins/jplan/plugin.json`.

**Acceptance Criteria:**

- [ ] `plugins/jplan/plugin.json` does not contain `"jp-planner"` in its `agents` array
- [ ] The JSON file remains valid after the edit

### REQ-005: Update README.md

**Description:** Update `README.md` to remove all references to `jms-git-push` and `jp-planner`. This includes the directory tree listing, the jinglemansweep skills list, and the jplan agents list.

**Acceptance Criteria:**

- [ ] The directory tree in README.md no longer lists `jms-git-push/`
- [ ] The jinglemansweep skills section no longer mentions `jms-git-push`
- [ ] The jplan agents section no longer mentions `jp-planner`
- [ ] The README remains well-formed Markdown with no broken formatting

## Non-Functional Requirements

### REQ-006: Repository Consistency

**Category:** Maintainability

**Description:** After all changes, there must be no dangling references to the removed components anywhere in the repository's tracked files (excluding `.plans/` and git history).

**Acceptance Criteria:**

- [ ] A repository-wide search for `jms-git-push` returns no matches outside `.plans/`
- [ ] A repository-wide search for `jp-planner` returns no matches outside `.plans/`

## Technical Constraints and Assumptions

### Constraints

- Changes are limited to file deletions and metadata/documentation edits; no new functionality is introduced
- The `install.sh` scripts are generic directory-copy scripts and do not need per-skill edits (they copy whatever is present in `skills/` and `agents/`)

### Assumptions

- The `jms-git-push` skill has no dependents -- no other skill or agent references or invokes it
- The `jp-planner` agent has no dependents -- no other skill or agent references or invokes it
- The `install.sh` scripts enumerate skills/agents dynamically from the filesystem and require no explicit updates

## Scope

### In Scope

- Deletion of `plugins/jinglemansweep/skills/jms-git-push/`
- Deletion of `plugins/jplan/agents/jp-planner.md`
- Updating `plugins/jinglemansweep/plugin.json` (remove skill entry)
- Updating `plugins/jplan/plugin.json` (remove agent entry)
- Updating `README.md` (remove references from tree, skill list, and agent list)

### Out of Scope

- Changes to any other skills or agents
- Changes to `marketplace.json` (it references plugins, not individual skills/agents)
- Changes to `install.sh` scripts (they operate on directory contents dynamically)
- Changes to `CLAUDE.md` (it does not reference individual skills by name)
- Any new features or functionality

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| N/A | N/A | This phase involves only file deletions and text edits; no technology stack applies |
