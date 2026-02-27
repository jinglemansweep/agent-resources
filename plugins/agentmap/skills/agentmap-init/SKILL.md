---
name: agentmap-init
description: Check for .agentmap.yaml and guide initial setup if missing
allowed-tools: Read, Edit, Glob, Grep, AskUserQuestion
---

<!-- tags: agentmap, codemap, orientation, setup -->
<!-- category: codebase-tools -->

# agentmap-init

Bootstrap agentmap support for a project.

## On Activation

When this skill is invoked, immediately:

1. Use Glob to check for `.agentmap.yaml` in the working directory (fall back to the repository root).
2. If the file **exists**, output:

```text
Agentmap already present — no setup needed.
Run `/agentmap-read` to load it or `/agentmap-generate` to regenerate.
```

Then continue to **Step 2** (auto-load instruction).

3. If the file is **not found**, inform the user and proceed through both steps below.

### Step 1 — Generate the agentmap

Use AskUserQuestion to ask whether to generate an agentmap now. Provide two options: "Yes, run /agentmap-generate" and "No, skip".

- If accepted, invoke the `agentmap-generate` skill.
- If declined, acknowledge and continue to Step 2.

### Step 2 — Add auto-load instruction

Offer to insert an auto-load instruction into the project's instruction file:

1. **Find the instruction file** — use Glob to check for `CLAUDE.md` at the repository root, then `AGENTS.md`. Use the first one found. If neither exists, skip this step entirely (do not create a new file).
2. **Check for existing instruction** — use Grep to search the found file for the string `agentmap-read`. If the string is already present, skip silently (this keeps the check idempotent).
3. **Ask the user** — use AskUserQuestion to offer inserting an auto-load instruction. Provide two options: "Yes, add it" and "No, skip".
4. **Insert if accepted** — if the user chooses yes, use Edit to insert the following line immediately after the first top-level heading (`#`) in the file (on the next line, before any existing content):

````markdown
AGENT INSTRUCTION: ALWAYS run `/agentmap-read` if skill and `.agentmap.yaml` exists in the project root to prime context
````

If the user declines, acknowledge and continue without changes.
