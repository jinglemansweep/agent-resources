# Implementation Plan

> Source: `.plans/20260226/03-documentation/prompt.md`

## Overview

Update `README.md` and `CLAUDE.md` to accurately reflect the current state of the repository. The documentation has drifted from reality — the plugin version has changed, six new role agents have been added, and minor description inconsistencies have crept in between `marketplace.json`, `plugin.json`, and `README.md`.

## Architecture & Approach

This is a documentation-only change. Both files will be updated to match the current filesystem and metadata. The approach is to reconcile all sources of truth (`plugin.json`, `marketplace.json`, the actual directory tree) and reflect them accurately in the two documentation files. Per the existing CLAUDE.md rule "Keep instructions general rather than listing specific file inventories to avoid staleness", the CLAUDE.md updates should remain high-level.

## Components

### README.md Updates

**Purpose:** Serve as the primary user-facing documentation for the repository — directory structure, plugin inventory, installation, and configuration.

**What needs to change:**
- **Version number**: Currently shows `0.1.0`, should be `0.2.0` (per `plugin.json`).
- **Directory tree**: Missing the six new role agent files (`jms-role-general.md`, `jms-role-python.md`, `jms-role-nodejs.md`, `jms-role-frontend.md`, `jms-role-devops.md`, `jms-role-docs.md`).
- **Agents list**: Only lists `jms-planner` and `jms-executor`. Needs all eight agents.
- **Description consistency**: Update the plugin tagline in README to match the new general description "Personal Skills and Agents" used in `marketplace.json` and `plugin.json`.

**Notes:** The directory tree and agents list are the core changes. The rest of the README content (installation, configuration, license) appears accurate and needs no changes.

### CLAUDE.md Updates

**Purpose:** Provide Claude Code with project context, conventions, and rules. Loaded into the system prompt.

**What needs to change:**
- **Project description**: Could mention the role agents as a category alongside planning/execution skills.
- **Directory tree snippet**: The minimal tree is fine per the "no specific file inventories" rule, but it could note that `agents/` contains both workflow agents and role-based agents without listing every file.
- **New convention**: Add a rule that `README.md` must be updated when skills or agents are added, removed, or renamed.

**Notes:** Changes here should be minimal. CLAUDE.md deliberately stays general, so it should not enumerate every agent. A brief mention that the plugin includes role-based specialist agents alongside the workflow agents is sufficient.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `README.md` | Modify | Update version, directory tree, agents list, and align descriptions |
| `CLAUDE.md` | Modify | Add brief mention of role-based agents and new convention about updating README |
| `marketplace.json` | Modify | Update description to "Personal Skills and Agents" |
| `plugin.json` | Modify | Update description to "Personal Skills and Agents" |
