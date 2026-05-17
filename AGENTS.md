# Agentic Dev Resources

Shared opencode configuration and customization resources.

## Conventions

- All markdown must pass markdownlint (80-char line limit, MD013)
- Pre-commit hooks are mandatory — run `pre-commit run --all-files`
  before committing
- JSON files must pass `check-json`, YAML must pass `check-yaml`
- No trailing whitespace, files must end with a newline

## Structure

- `opencode/opencode.json` — opencode server and MCP configuration.
  Environment variable references use `{env:VAR_NAME}` syntax
- `opencode/commands/*.md` — Slash commands. Each has a YAML front
  matter `description` field followed by the prompt body
- `opencode/skills/<name>/SKILL.md` — Skills. Each has YAML front
  matter with `name`, `description`, `license`, `compatibility`,
  `metadata` fields, then the skill instructions in markdown
- `opencode/agents/*.md` — Agent definitions. Each has YAML front
  matter with `description`, `mode`, `permission` fields, then the
  agent system prompt in markdown

## Editing Rules

- Do not hardcode API keys or secrets — use `{env:VAR_NAME}` in
  opencode.json
- When adding a new MCP server, document it in README.md and list
  required environment variables
- When adding a new command or skill, follow the existing front
  matter format exactly
- Keep SKILL.md front matter on a single line for `description` and
  `triggers` fields
