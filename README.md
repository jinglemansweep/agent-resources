# agent-resources

A collection of Claude Code plugins (skills and agents) distributed as a plugin marketplace. The repository currently contains the `plan-quick` plugin for planning workflows, and is designed to host multiple plugins.

Licensed under GPL-3.0.

## Directory Structure

```
marketplace.json            # Marketplace metadata listing available plugins
plugins/                    # Directory containing all plugins
  plan-quick/               # The plan-quick plugin
    plugin.json             # Plugin metadata (name, version, skills, agents)
    install.sh              # Installation script
    skills/                 # Skill definitions
      pq-init/
      pq-phase-new/
      pq-plan/
      pq-review/
      pq-taskify/
      pq-execute/
    agents/                 # Agent definitions
      pq-planner.md
      pq-executor.md
LICENSE                     # GPL-3.0 license
README.md                   # This file
```

## Plugins

### plan-quick

Quick and simple Plan, Review, Taskify and Execute skills.

**Version:** 0.1.0

**Skills:**

- `pq-init` — Initialize the `.plans` directory structure for a project
- `pq-phase-new` — Create a new datestamped planning phase directory
- `pq-plan` — Generate a high-level implementation plan from a prompt
- `pq-review` — Review and resolve issues in a plan
- `pq-taskify` — Generate a detailed task list from a plan
- `pq-execute` — Implement tasks from a task list with quality gates and commits

**Agents:**

- `pq-planner` — Guides through the full planning workflow (init, phase selection, plan creation, issue review, and task list generation)
- `pq-executor` — Confirms a plan phase directory and executes its task list group by group

## Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   ```
2. Navigate to the plugin directory:
   ```bash
   cd plugins/plan-quick
   ```
3. Run the install script:
   ```bash
   bash install.sh
   ```

This copies skills into `~/.claude/skills/` and agents into `~/.claude/agents/`.

To install to a custom location, set the `CLAUDE_DIR` environment variable:

```bash
CLAUDE_DIR=/path/to/custom/.claude bash install.sh
```

## Configuration

Plugins may include their own `.claude/settings.local.json` with plugin-specific settings. The `plan-quick` plugin includes a settings file at `plugins/plan-quick/.claude/settings.local.json` which configures automatic permission for the `pq-init` skill:

```json
{
  "permissions": {
    "allow": [
      "Skill(pq-init)"
    ]
  }
}
```

The `install.sh` script copies skill and agent files but does not copy settings. Users may need to merge plugin settings into their own `.claude/settings.local.json` depending on their environment.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
