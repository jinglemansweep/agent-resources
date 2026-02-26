# Task List

> Source: `.plans/20260226/03-documentation/plan.md`

## Metadata Alignment

### Description Consistency

- [x] **Update `marketplace.json` top-level description** — In `marketplace.json`, change the top-level `"description"` value from `"Infrastructure, homelab, and mesh networking skills"` to `"Personal Skills and Agents"`. Verify by reading the file and confirming the value matches exactly.

- [x] **Update `marketplace.json` plugin description** — In `marketplace.json`, change the `plugins[0].description` value from `"Quick and simple Plan, Research, Taskify and Execute skills"` to `"Personal Skills and Agents"`. Verify by reading the file and confirming the value matches exactly.

- [x] **Update `plugin.json` description** — In `plugins/jinglemansweep/plugin.json`, change the `"description"` value from `"Quick and simple Plan, Review, Taskify and Execute skills"` to `"Personal Skills and Agents"`. Verify by reading the file and confirming the value matches exactly.

## README.md Updates

### Version and Description

- [x] **Update plugin version in README.md** — In `README.md`, change `**Version:** 0.1.0` to `**Version:** 0.2.0` (line 35). This aligns with the version in `plugins/jinglemansweep/plugin.json`.

- [x] **Update plugin tagline in README.md** — In `README.md`, change the plugin description `Quick and simple Plan, Review, Taskify and Execute skills.` (line 33) to `Personal Skills and Agents.` to match the updated metadata files.

- [x] **Update repository introduction in README.md** — In `README.md`, change line 3 from `A personal Claude Code agent and skill toolkit. The repository currently contains the 'jinglemansweep' plugin for planning workflows, and is designed to host multiple plugins.` to `A personal Claude Code agent and skill toolkit. Currently hosts the 'jinglemansweep' plugin.` to align with CLAUDE.md and reflect that the plugin now covers more than just planning workflows.

### Directory Tree

- [x] **Add role agent files to directory tree in README.md** — In the `Directory Structure` code block in `README.md`, add the six new role agent files under the `agents/` directory so the full agents section reads:
  ```
      agents/                 # Agent definitions
        jms-planner.md
        jms-executor.md
        jms-role-general.md
        jms-role-python.md
        jms-role-nodejs.md
        jms-role-frontend.md
        jms-role-devops.md
        jms-role-docs.md
  ```
  Verify the tree matches the actual filesystem by comparing with `ls plugins/jinglemansweep/agents/`.

### Agents List

- [x] **Add role agents to the agents list in README.md** — In the `**Agents:**` section under the jinglemansweep plugin (after line 49), add the six new role agents so the full agents list reads:
  ```
  - `jms-planner` — Guides through the full planning workflow (init, phase selection, plan creation, issue review, and task list generation)
  - `jms-executor` — Confirms a plan phase directory and executes its task list group by group
  - `jms-role-general` — General-purpose implementation specialist for mixed or unclassified tasks
  - `jms-role-python` — Python backend implementation specialist
  - `jms-role-nodejs` — JavaScript/TypeScript/Node implementation specialist
  - `jms-role-frontend` — Frontend/UI implementation specialist
  - `jms-role-devops` — Infrastructure and CI/CD implementation specialist
  - `jms-role-docs` — Documentation implementation specialist
  ```
  Verify descriptions match the frontmatter in each agent's `.md` file.

## CLAUDE.md Updates

### Project Description

- [ ] **Mention role-based agents in CLAUDE.md project description** — In `CLAUDE.md`, update the `# Project` section description to briefly note that the plugin includes both workflow agents (planning/execution) and role-based specialist agents, without listing every agent file. For example, change `Personal Claude Code agent and skill toolkit. Currently hosts the 'jinglemansweep' plugin.` to `Personal Claude Code agent and skill toolkit. Currently hosts the 'jinglemansweep' plugin, which provides planning/execution workflow skills and role-based specialist agents.`

### New Convention

- [ ] **Add README update convention to CLAUDE.md** — In the `# Rules` section of `CLAUDE.md`, add a new bullet: `- Update 'README.md' when skills or agents are added, removed, or renamed.` This addresses the resolved future consideration from `issues.md` about documentation drift.
