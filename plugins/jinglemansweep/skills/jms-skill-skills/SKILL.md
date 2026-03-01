---
name: jms-skill-skills
description: Skill authoring conventions and quality gates
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

<!-- tags: skill, authoring, skill-creator, conventions, quality -->
<!-- category: domain-skills -->

# jms-skill-skills

Skill authoring conventions, quality gates, and domain knowledge for creating and modifying SKILL.md files. Loaded by the jms-developer agent when handling skill-related tasks. This is not a user-invocable skill.

## Skill-Creator Guidance

Before writing or modifying any SKILL.md file, read the skill-creator skill's authoring guidance at:

```text
~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/skill-creator/SKILL.md
```

Follow the "Skill Writing Guide" section in that file, including its guidance on anatomy, progressive disclosure, writing patterns, and writing style. This is the primary reference for how a well-structured SKILL.md should read.

## Project Skill Conventions

In addition to the skill-creator guidance, adhere to the project's own conventions:

- Each skill lives under `plugins/<plugin-name>/skills/<skill-name>/`
- Each skill directory contains a single `SKILL.md` file -- no auxiliary files unless necessary
- SKILL.md files use YAML frontmatter with `name`, `description`, and `allowed-tools` fields
- Skills are self-contained -- all instructions and context live in the one file
- Plugin-scoped skills use the plugin's short prefix for naming (e.g. `jms-` for `jinglemansweep`)

## Domain Expertise

- SKILL.md structure and anatomy (frontmatter, sections, progressive disclosure)
- Markdown: GFM syntax, headings, code blocks, tables, lists
- Clear, concise technical writing -- match the project's existing tone and style
- Understanding of Claude Code skill conventions and how skills are invoked
- Familiarity with the skill-creator's writing patterns (action-oriented, direct, no filler)
- Auditing existing skill files for structural and content consistency

## Rules

- Every SKILL.md must have valid YAML frontmatter with `name`, `description`, and `allowed-tools` fields
- Follow the skill-creator's writing patterns: direct instructions, progressive disclosure, no filler prose
- Do not invent features or capabilities that do not exist in the codebase
- Preserve the existing structure and style of skill files when editing
- One SKILL.md per skill directory -- do not split content across multiple files

## Workflow

1. **Read the skill-creator guidance** -- open and review the skill-creator SKILL.md to refresh the authoring patterns before writing.
2. **Audit existing skill files** -- if modifying an existing skill, read the current SKILL.md and any related skills to understand the established content, structure, and style.
3. **Write or edit the SKILL.md** -- create or modify the skill file following the skill-creator's patterns and the project's conventions.
4. **Verify frontmatter and structure** -- confirm the SKILL.md has valid YAML frontmatter with `name`, `description`, and `allowed-tools` fields, and that the file follows the expected section structure.

## Quality Gates

After every unit of work, run the following gates. Do not skip them.

- Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
- If the gate fails, fix the issue before moving on
