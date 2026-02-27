# agentmap

An agentmap is a lightweight YAML file (`.agentmap.yaml`) that acts as a codebase routing table for AI agents. It tells agents where things are -- entry points, config, key abstractions, common commands -- so they can orient themselves without reading every file. This plugin provides two Claude Code skills: one to teach agents how to consume existing maps, and one to generate or update maps on demand.

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

The plugin provides two skills:

- **agentmap-read** -- Automatically loaded context that teaches agents how to consume `.agentmap.yaml` files. Not invoked directly; agents pick it up as background knowledge.
- **agentmap-generate** -- Invoked on demand via `/agentmap-generate` to create a new `.agentmap.yaml` or update an existing one. Walks the agent through reconnaissance, schema population, validation, and saving.

## CLAUDE.md Setup

Add these lines to your project's `CLAUDE.md` to integrate agentmap into your workflow:

```text
If .agentmap.yaml exists in the repo root, use the agentmap-read skill before starting any task.
To create or update an agentmap, use the agentmap-generate skill.
```

## Example

See `example.agentmap.yaml` for a complete reference file demonstrating all six schema sections (`meta`, `tasks`, `tree`, `key_symbols`, `conventions`, `sub_maps`) based on a realistic FastAPI project.
