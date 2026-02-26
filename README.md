# agent-resources

A personal Claude Code agent and skill toolkit. Currently hosts the `jinglemansweep` plugin.

Licensed under GPL-3.0.

## Directory Structure

```
marketplace.json            # Marketplace metadata listing available plugins
plugins/                    # Directory containing all plugins
  jinglemansweep/               # The jinglemansweep plugin
    plugin.json             # Plugin metadata (name, version, skills, agents)
    install.sh              # Installation script
    skills/                 # Skill definitions
      jms-init/
      jms-phase-new/
      jms-plan/
      jms-review/
      jms-taskify/
      jms-execute/
    agents/                 # Agent definitions
      jms-planner.md
      jms-role-general.md
      jms-role-python.md
      jms-role-nodejs.md
      jms-role-frontend.md
      jms-role-devops.md
      jms-role-docs.md
LICENSE                     # GPL-3.0 license
README.md                   # This file
```

## Plugins

### jinglemansweep

Personal Skills and Agents.

**Version:** 0.2.0

**Skills:**

- `jms-init` — Initialize the `.plans` directory structure for a project
- `jms-phase-new` — Create a new datestamped planning phase directory
- `jms-plan` — Generate a high-level implementation plan from a prompt
- `jms-review` — Review and resolve issues in a plan
- `jms-taskify` — Generate a detailed task list from a plan
- `jms-execute` — Implement tasks from a task list with quality gates and commits

**Agents:**

- `jms-planner` — Guides through the full planning workflow (init, phase selection, plan creation, issue review, and task list generation)
- `jms-role-general` — General-purpose implementation specialist for mixed or unclassified tasks
- `jms-role-python` — Python backend implementation specialist
- `jms-role-nodejs` — JavaScript/TypeScript/Node implementation specialist
- `jms-role-frontend` — Frontend/UI implementation specialist
- `jms-role-devops` — Infrastructure and CI/CD implementation specialist
- `jms-role-docs` — Documentation implementation specialist

## Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   ```
2. Navigate to the plugin directory:
   ```bash
   cd plugins/jinglemansweep
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

Plugins may include their own `.claude/settings.local.json` with plugin-specific settings. The `jinglemansweep` plugin includes a settings file at `plugins/jinglemansweep/.claude/settings.local.json` which configures automatic permission for the `jms-init` skill:

```json
{
  "permissions": {
    "allow": [
      "Skill(jms-init)"
    ]
  }
}
```

The `install.sh` script copies skill and agent files but does not copy settings. Users may need to merge plugin settings into their own `.claude/settings.local.json` depending on their environment.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
