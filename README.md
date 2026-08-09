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
    ├── agents/                   # Custom agent definitions
    │   ├── qwen-image-generation.md  # QwenCloud Token Plan image generation
    │   └── qwen-video-generation.md  # QwenCloud Token Plan video generation
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

## Custom Agents

### qwen-image-generation

Generates images from text descriptions via the QwenCloud Token Plan
text-to-image API. Extracts the prompt, model, and size from the user
request (default model `qwen-image-3.0`, default size `1024*1024`),
calls the multimodal generation endpoint, and downloads the resulting
image to the current directory.

### qwen-video-generation

Generates videos via the QwenCloud Token Plan video generation API
using the `happyhorse-1.1-t2v` (text-to-video), `happyhorse-1.1-i2v`
(image-to-video), and `happyhorse-1.1-r2v` (reference-to-video)
models. Uses an asynchronous task pattern: submit a synthesis task,
poll the task status, then download the video to the current
directory.

Both agents require the `QWENCLOUD_API_KEY` environment variable
(QwenCloud Token Plan API key) to be set.

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
