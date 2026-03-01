---
name: jms-skill-docs
description: Documentation conventions and quality gates
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

<!-- tags: documentation, readme, changelog, markdown, conventions, quality -->
<!-- category: domain-skills -->

# jms-skill-docs

Documentation writing conventions, quality gates, and domain knowledge. Loaded by the jms-developer agent when handling documentation tasks. This is not a user-invocable skill.

## Documentation Scope

When auditing and updating documentation, consider **all** documentation files in the repository, not just the README. Common files include:

| File | Purpose |
|---|---|
| `README.md` | Primary project documentation -- structure, usage, installation |
| `CLAUDE.md` | Claude Code agent instructions and project conventions |
| `AGENTS.md` | Codex / OpenAI agent instructions |
| `.github/copilot-instructions.md` | GitHub Copilot custom instructions |
| `CONTRIBUTING.md` | Contribution guidelines |
| `CHANGELOG.md` | Version history (Keep a Changelog format) |
| `.cursor/rules/*.mdc` | Cursor IDE rules |

Not every project will have all of these. Only create files that are explicitly requested or already exist. When updating, keep content consistent across all documentation files.

## README Badges

Badges are a **mandatory** part of every README. They must appear immediately after the top-level heading (`# Title`), before any description text.

**Required badges:**

1. **GitHub Actions workflow badges** -- scan `.github/workflows/` for every `.yml`/`.yaml` file. Each workflow must have a corresponding status badge. Use the format:
   `![Workflow Name](https://github.com/OWNER/REPO/actions/workflows/FILENAME/badge.svg)`
2. **License badge** -- always present if a `LICENSE` file exists. Use shields.io with the correct SPDX identifier, e.g.:
   `![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)`

**Placement rules:**

- Badges go on the line immediately after the `# Title` heading
- One blank line between the title and the badge row
- One blank line between the badge row and the description text
- All badges on a single line, separated by spaces

## Domain Expertise

- Markdown: GFM syntax, structure, headings, tables, code blocks
- README conventions: badges, install instructions, usage examples, contributing guides
- AI agent instruction files: CLAUDE.md, AGENTS.md, .github/copilot-instructions.md, .cursor/rules/
- API documentation: endpoint descriptions, request/response examples
- Changelog: Keep a Changelog format, semantic versioning references
- Clear, concise technical writing -- match the project's existing tone and style
- Codebase auditing: systematically reading source files to build a complete picture
- Cross-referencing documentation against implementation

## Rules

- Every claim in documentation must be verifiable in the codebase
- Do not invent or assume features that do not exist
- Do not remove documentation sections that are still accurate
- Preserve the existing structure and style of each documentation file

## Workflow

1. **Audit the codebase** -- thoroughly read source files, configuration, and tests to build a complete picture of the project's current state, features, and behaviour.
2. **Review existing documentation** -- read all documentation files to understand current coverage, structure, and style.
3. **Remove stale content** -- delete or update references to features, options, or functionality that no longer exist.
4. **Add missing content** -- document any features, configuration, components, or behaviour not yet covered.
5. **Verify accuracy** -- cross-check documented examples, defaults, file paths, and option names against the actual implementation and fix discrepancies.
6. **Sync agent instruction files** -- if CLAUDE.md, AGENTS.md, .github/copilot-instructions.md, or .cursor/rules/ exist, verify they are consistent with each other and with the codebase.

## Quality Gates

After every unit of work, run the following gates. Do not skip them.

- Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists (this covers markdownlint and other doc-related hooks)
- If the gate fails, fix the issue before moving on
