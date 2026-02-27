# agentmap

An agentmap is a lightweight YAML file (`.agentmap.yaml`) that acts as a codebase routing table for AI agents. It tells agents where things are -- entry points, config, key abstractions, common commands -- so they can orient themselves without reading every file. This plugin provides three Claude Code skills: one to check for and guide initial setup, one to teach agents how to consume existing maps, and one to generate or update maps on demand.

## Installation

The `install.sh` script copies skills to `~/.claude/skills/` and reference files to `~/.claude/agentmap/`.

```bash
cd plugins/agentmap && bash install.sh
```

To install to a custom location, set the `CLAUDE_DIR` environment variable:

```bash
CLAUDE_DIR=/path/to/custom/.claude bash install.sh
```

## Usage

The plugin provides three skills:

- **agentmap-init** -- Check for `.agentmap.yaml` and guide initial setup if missing. Run via `/agentmap-init`.
- **agentmap-read** -- Automatically loaded context that teaches agents how to consume `.agentmap.yaml` files. Not invoked directly; agents pick it up as background knowledge.
- **agentmap-generate** -- Invoked on demand via `/agentmap-generate` to create a new `.agentmap.yaml` or update an existing one. Walks the agent through reconnaissance, schema population, validation, and saving.

## CLAUDE.md Setup

Run `/agentmap-init` to automatically insert the auto-load instruction, or manually add this line immediately after the first heading in your project's `CLAUDE.md`:

```text
AGENT INSTRUCTION: ALWAYS run `/agentmap-read` if skill and `.agentmap.yaml` exists in the project root to prime context
```

## Example

See `example.agentmap.yaml` for a complete reference file demonstrating all six schema sections (`meta`, `tasks`, `tree`, `key_symbols`, `conventions`, `sub_maps`) based on a realistic FastAPI project.
