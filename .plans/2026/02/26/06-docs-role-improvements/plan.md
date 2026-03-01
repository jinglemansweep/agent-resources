# Implementation Plan

> Source: `.plans/20260226/06-docs-role-improvements/prompt.md`

## Overview

Add structured workflow sections to all role agents, starting with the docs agent (which also gets accuracy rules and expanded domain expertise). Each agent receives a guidance-oriented workflow tailored to its domain, providing procedural guidance on how to approach tasks without being over-prescriptive.

## Architecture & Approach

The current role agents describe domain expertise, quality gates, and constraints, but provide no procedural guidance on **how** to approach a task. The referenced documentation-update skill demonstrates the value of a defined workflow. This plan extends that pattern to all six role agents.

The approach:

1. **Guidance-oriented steps** — each workflow step is described as a principle with brief explanation. The agent adapts to the project context. No hardcoded commands or checklists within the workflow (quality gates remain in their own section).
2. **Domain-tailored workflows** — each agent's workflow reflects its specialty. The docs agent follows audit → review → remove stale → add missing → verify → summarise. The Python agent follows understand → implement → test → verify. Each workflow is unique to the domain.
3. **Consistent placement** — the Workflow section is placed after Domain Expertise (or after any domain-specific subsections like Preferred Stack) and before Quality Gates, in all agents. This maintains a natural reading order: what you know → how you work → what checks you run → what constraints apply.
4. **Docs agent extras** — the docs agent additionally gets a Rules section (accuracy principles) and expanded Domain Expertise, as these are documentation-specific and inspired by the referenced skill.
5. **Structured summaries** — where a workflow includes a summary/reporting step, use a structured list format (categorised as added, removed, corrected/changed).

## Components

### Docs Agent: Workflow Section

**Purpose:** Provide a repeatable process for documentation tasks: audit the codebase, review existing docs, remove stale content, add missing content, verify accuracy, and summarise changes.

**Inputs:** The task description from `tasks.md`.

**Outputs:** Updated documentation files that are accurate, complete, and verified against the codebase. A structured summary of changes.

**Notes:** Step 6 from the reference (run quality checks) is already covered by Quality Gates and should not be duplicated — the workflow should reference Quality Gates. The summary step uses structured list format.

### Docs Agent: Rules Section

**Purpose:** Codify accuracy and integrity principles: verifiability, no fabrication, preserve accurate content, match existing style.

**Notes:** Placed between Domain Expertise and Workflow. Distinct from Constraints (which cover task-execution mechanics). These are documentation-quality principles drawn from the referenced skill's rules.

### Docs Agent: Domain Expertise Expansion

**Purpose:** Add 2-3 bullet points covering codebase auditing, cross-referencing docs against implementation, and identifying stale/missing content.

**Notes:** Minimal additions — don't bloat the existing list.

### Python Agent: Workflow Section

**Purpose:** Guide the Python agent through implementation tasks: understand the existing code and patterns, implement changes following project conventions, write/update tests, verify everything works.

**Notes:** Should emphasise virtualenv activation as a first step (aligning with the agent's existing Mandatory Requirements). Summary step for reporting what was implemented and any decisions made.

### Node.js Agent: Workflow Section

**Purpose:** Guide the Node.js agent through implementation tasks: understand existing code and package setup, implement changes following project conventions, write/update tests, verify builds pass.

**Notes:** Should cover checking the package manager and existing tooling as a first step.

### Frontend Agent: Workflow Section

**Purpose:** Guide the frontend agent through UI tasks: understand the existing component structure and design system, implement changes following existing patterns, verify visual correctness and accessibility, test builds.

**Notes:** Should reference the agent's existing Preferred Stack and Responsive & Theming sections. Emphasise checking existing component conventions before creating new patterns.

### DevOps Agent: Workflow Section

**Purpose:** Guide the DevOps agent through infrastructure tasks: understand existing infrastructure and CI/CD setup, implement changes following existing patterns, validate configurations, verify deployments/builds.

**Notes:** Should emphasise reviewing existing pipelines and infrastructure before making changes. Validation steps should reference domain-specific tools (terraform validate, shellcheck, etc.) already in Quality Gates.

### General Agent: Workflow Section

**Purpose:** Guide the general-purpose agent through mixed tasks: understand the project context and conventions, implement changes following existing patterns, verify correctness.

**Notes:** Keep this workflow the most generic — the general agent handles mixed/unclassified tasks, so the workflow should be adaptable. Focus on understanding context and following existing conventions.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `plugins/jinglemansweep/agents/jms-role-docs.md` | Modify | Add Workflow section, Rules section, and expand Domain Expertise |
| `plugins/jinglemansweep/agents/jms-role-python.md` | Modify | Add Workflow section |
| `plugins/jinglemansweep/agents/jms-role-nodejs.md` | Modify | Add Workflow section |
| `plugins/jinglemansweep/agents/jms-role-frontend.md` | Modify | Add Workflow section |
| `plugins/jinglemansweep/agents/jms-role-devops.md` | Modify | Add Workflow section |
| `plugins/jinglemansweep/agents/jms-role-general.md` | Modify | Add Workflow section |
