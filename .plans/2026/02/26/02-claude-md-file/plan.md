# Implementation Plan

> Source: `.plans/20260226/02-claude-md-file/prompt.md`

## Overview

Add a `CLAUDE.md` file to the repository root that gives Claude Code project-specific context when working in this codebase. The file will cover the project's purpose and structure, coding conventions, and rules/constraints for making changes.

## Architecture & Approach

`CLAUDE.md` is a convention recognized by Claude Code -- when present in a repository root, its contents are automatically loaded as project instructions. The file should be written in Markdown and organized into clearly separated sections so that Claude can quickly locate relevant guidance.

The content should be derived from what already exists in the repository: the `README.md` describes the project purpose and structure, `marketplace.json` and `plugin.json` define the plugin system, and the existing skill/agent files establish the patterns and conventions in use. The `CLAUDE.md` should distill this into actionable instructions rather than duplicating the README.

Since this project is a plugin marketplace (skills and agents for Claude Code), the conventions section should address how plugins are structured, how skills and agents are defined, and the naming conventions already in use (e.g., `pq-` prefix for the plan-quick plugin). The rules section should cover constraints like license compatibility (GPL-3.0), file organization expectations, and what Claude should or should not modify.

## Components

### Project Overview Section

**Purpose:** Give Claude a concise understanding of what this repository is, who it is for, and how it is organized.
**Inputs:** Information from `README.md`, `marketplace.json`, and the directory structure.
**Outputs:** A brief section in `CLAUDE.md` covering project identity, purpose, and directory layout.
**Notes:** This should be a compact summary, not a copy of the README. Focus on what Claude needs to know to make useful contributions -- the plugin system, the marketplace concept, and the directory conventions. Show only the top-level directory structure and refer to `README.md` for the full tree.

### Coding Conventions Section

**Purpose:** Document the patterns and practices used in this codebase so Claude follows them consistently.
**Inputs:** Observed patterns from existing files -- skill structure (`SKILL.md` files), agent structure (Markdown agent definitions), plugin metadata (`plugin.json`), naming conventions, and Markdown formatting style.
**Outputs:** A section in `CLAUDE.md` listing conventions for file naming, directory structure, Markdown formatting, JSON structure, and plugin organization.
**Notes:** Conventions should be stated as clear directives (e.g., "Skill directories contain a single `SKILL.md` file") rather than descriptive observations. Cover naming patterns like the `pq-` prefix convention for plugin-scoped resources. Scope to current plan-quick plugin patterns only; do not establish speculative conventions for future plugins.

### Rules Section

**Purpose:** Define hard constraints and guidelines that Claude must follow when making changes to the repository.
**Inputs:** Project license (GPL-3.0), existing `.claude/settings.local.json` patterns, and general repository hygiene expectations.
**Outputs:** A section in `CLAUDE.md` with explicit rules covering what Claude should and should not do.
**Notes:** Rules should include: respect the GPL-3.0 license, do not modify `LICENSE`, follow the existing plugin directory structure, do not add dependencies without discussion, keep skills self-contained (one `SKILL.md` per skill directory), and maintain backward compatibility with the `install.sh` script.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `CLAUDE.md` | Create | Project instructions, coding conventions, and rules for Claude Code |
