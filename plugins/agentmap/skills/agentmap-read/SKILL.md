---
name: agentmap-read
description: Teaches agents how to consume .agentmap.yaml codebase orientation maps
allowed-tools: Read, Glob
---

<!-- tags: agentmap, codemap, orientation, reading -->
<!-- category: codebase-tools -->

# agentmap-read

`.agentmap.yaml` is a codebase routing table -- read it before starting any task.

## On Activation

When this skill is invoked, immediately:

1. Look for `.agentmap.yaml` in the working directory (fall back to the repository root).
2. Read the file contents into context using the Read tool.
3. Output a short confirmation summary using this template:

```text
Agentmap loaded: **<meta.project>** (schema v<meta.version>, updated <meta.updated>)
Stack: <meta.stack joined with ", ">
Top-level entries: <count of tree root keys> | Conventions: <count of conventions>
```

If the file is not found, state that no agentmap was found and suggest running `/agentmap-init` to set one up.

## Schema Sections

- **meta** -- project identity and stack
- **tasks** -- common shell commands (install, build, test, run, lint)
- **tree** -- annotated directory layout with terse descriptions
- **key_symbols** -- important code entities with path, name, and tags
- **conventions** -- project patterns and rules
- **sub_maps** -- monorepo delegation to nested `.agentmap.yaml` files

## Staleness

Check the `updated` field against recent git activity. A stale map may reference files or symbols that no longer exist.

## Caveats

This is an index, not a substitute for reading code -- always verify by reading the actual files.

## Version

This skill covers schema v1. Check the `version` field in the agentmap; if it is not `1`, this guidance may not fully apply.
