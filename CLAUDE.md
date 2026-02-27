# Project

Personal Claude Code agent and skill toolkit. Currently hosts the `jinglemansweep` and `agentmap` plugins.

```text
marketplace.json   — Marketplace metadata listing available plugins
plugins/           — All plugins, each in its own subdirectory
LICENSE            — GPL-3.0 license
README.md          — Full directory tree and detailed documentation
```

See `README.md` for the complete directory structure and plugin documentation.

## Conventions

- Plugins live under `plugins/<plugin-name>/` and contain `plugin.json`, `install.sh`, `skills/`, and `agents/` directories.
- Each skill is a directory under `skills/` containing a single `SKILL.md` file.
- Each agent is a single Markdown file in the `agents/` directory.
- Plugin-scoped resources use a short prefix for skill and agent names (e.g. `jms-` for `jinglemansweep`).
- Metadata files (`marketplace.json`, `plugin.json`) are JSON.
- All documentation and skill/agent definitions use Markdown.

## Rules

- Respect the GPL-3.0 license; do not modify `LICENSE`.
- Follow the existing plugin directory structure when adding or modifying plugins.
- Do not add external dependencies without discussing with the user first.
- Keep skills self-contained — one `SKILL.md` per skill directory, no auxiliary files unless necessary.
- Maintain backward compatibility with the `install.sh` script.
- Keep instructions general rather than listing specific file inventories to avoid staleness.
- Update `README.md` when skills or agents are added, removed, or renamed.
- Never add `Co-Authored-By` trailers to git commit messages.
