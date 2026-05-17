# Agentic Dev Resources

Shared configuration and customization resources for
[opencode](https://opencode.ai) — an AI-powered coding agent CLI.

## Directory Structure

```text
.
├── .pre-commit-config.yaml       # Pre-commit hooks (JSON, YAML, markdown, shellcheck)
├── LICENSE                       # GPL-3.0
└── opencode/
    ├── opencode.json             # opencode configuration (server, MCP servers)
    ├── agents/                   # Custom agent definitions (placeholder)
    ├── commands/                 # Custom slash commands
    │   └── git-commit.md         # /git-commit command
    └── skills/                   # Custom skills
        └── docs-writer/
            └── SKILL.md          # Documentation generation specialist
```

## opencode Configuration

The `opencode/opencode.json` file configures:

- **Server** — Local dev server on port 4096 with CORS for local and remote origins
- **MCP Servers** — Remote and local tool servers:
  - `context7` — Library documentation lookup (remote, requires `CONTEXT7_API_KEY`)
  - `zread` — GitHub repository reading (remote, requires `ZAI_API_KEY`)
  - `web-reader` — Web page fetching and conversion (remote, requires `ZAI_API_KEY`)
  - `web-search-prime` — Web search (remote, requires `ZAI_API_KEY`)
  - `zai-mcp-server` — Image and video analysis tools (local, requires `ZAI_API_KEY`)

### Environment Variables

| Variable | Used By | Description |
|---|---|---|
| `CONTEXT7_API_KEY` | context7 | API key for Context7 documentation service |
| `ZAI_API_KEY` | zread, web-reader, | API key for Z AI services |
| | web-search-prime, | |
| | zai-mcp-server | |

## Custom Commands

### `/git-commit`

Stages changes, runs quality gates, and creates a commit. The command:

1. Inspects staged/unstaged changes
2. Runs pre-commit hooks or language-appropriate linters
3. Stages relevant files
4. Creates a commit with an imperative-mood message
5. Confirms the working tree state

## Custom Skills

### docs-writer

A documentation specialist skill that generates and validates technical
documentation including docstrings, API specs, JSDoc annotations, and
markdown files. Supports Google-style and NumPy-style Python docstrings,
JSDoc for TypeScript, and OpenAPI specifications. Includes a markdown
synchronization workflow that cross-references documentation against the
actual codebase to ensure accuracy.

## Pre-commit Hooks

The `.pre-commit-config.yaml` configures:

- **pre-commit-hooks** (v5.0.0) — JSON/YAML validation, trailing whitespace,
  end-of-file fixes, merge conflict detection, large file checks,
  private key detection
- **shellcheck** (v0.10.0) — Shell script linting

## License

Licensed under [GPL-3.0](LICENSE).
