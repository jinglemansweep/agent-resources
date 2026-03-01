# Add Pre-Commit Configuration

## Overview

Add a pre-commit configuration to this repository to enforce consistent formatting and catch errors in committed files.

## Repository Context

This repo contains primarily Markdown (`.md`), JSON (`.json`), and shell (`.sh`) files. There are no application-language source files — it is a toolkit of Claude Code skills and agent definitions.

## Requirements

- Add a `.pre-commit-config.yaml` to the repository root
- Use the [pre-commit](https://pre-commit.com/) framework
- Include hooks relevant to the file types in this repo:
  - **Markdown**: lint and validate (e.g. `markdownlint`)
  - **JSON**: validate syntax (e.g. `check-json` from `pre-commit-hooks`)
  - **YAML**: validate syntax (e.g. `check-yaml` from `pre-commit-hooks`)
  - **Shell**: lint shell scripts (e.g. `shellcheck`)
  - **General**: trailing whitespace, end-of-file fixer, merge conflict markers, large file checks (from `pre-commit-hooks`)
- Keep the configuration minimal and appropriate — do not add hooks for languages or tools not used in this repo
- Add a `.markdownlint.yaml` (or `.markdownlint-cli2.yaml`) config if needed to suppress noisy rules that conflict with the existing file style (e.g. line length)
