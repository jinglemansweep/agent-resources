## TASK-001: Add markdownlint and yamllint detection to Step 2
**Status:** completed
### Files Modified
- `plugins/jplan/skills/jp-task-validate/SKILL.md`
### Notes
Added markdownlint config file detection (5 filenames), yamllint config file detection (3 filenames), and a new PATH availability checks paragraph for markdownlint/markdownlint-cli2, yamllint, and shellcheck CLI tools. Updated closing sentence to mention PATH availability. All entries follow existing format and style.
---

## TASK-002: Add markdownlint routing for Markdown files in Step 3
**Status:** completed
### Files Modified
- `plugins/jplan/skills/jp-task-validate/SKILL.md`
### Notes
Added a "Markdown files" subsection to Step 3 between YAML and Shell scripts. Uses conditional markdownlint/markdownlint-cli2 invocation with silent skip when unavailable. Captures errors with file path and line number, prefixes findings with tool name.
---

## TASK-003: Update yamllint routing for YAML files in Step 3
**Status:** completed
### Files Modified
- `plugins/jplan/skills/jp-task-validate/SKILL.md`
### Notes
Restructured YAML subsection from a single-line entry to a tiered two-item list: yamllint preferred when available (replaces basic syntax check), Python yaml.safe_load as fallback. Follows the same pattern as Python (ruff/flake8) and Shell (shellcheck/bash -n) subsections. Tool name prefixing added.
---

## TASK-004: Verify full SKILL.md consistency and graceful degradation
**Status:** completed
### Files Modified
- (none -- verification only, no changes needed)
### Notes
Full consistency review passed. Step 8 report format accommodates new tool findings generically. Guidelines section remains accurate. All Step 2 detections map to Step 3 routing and vice versa. All conditional linter invocations have clear fallback or silent skip. Formatting is consistent between new and existing subsections.
---
