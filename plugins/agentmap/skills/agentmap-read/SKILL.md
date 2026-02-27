---
name: agentmap-read
description: Teaches agents how to consume .agentmap.yaml codebase orientation maps
---

<!-- tags: agentmap, codemap, orientation, reading -->
<!-- category: codebase-tools -->

# agentmap-read

`.agentmap.yaml` is a codebase routing table -- read it before starting any task.

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
