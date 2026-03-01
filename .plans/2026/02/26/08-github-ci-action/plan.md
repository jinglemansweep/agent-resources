# Implementation Plan

> Source: `.plans/20260226/08-github-ci-action/prompt.md`

## Overview

Add a GitHub Actions workflow that runs the project's pre-commit hooks as a mandatory status check on pull requests targeting the default branch. Enhance the `jms-plan` skill's research stage to include cross-component compatibility analysis, web/GitHub issue searches to verify chosen components work together, and a licence breakdown for all external dependencies. Additionally, update the README title from "agent-resources" to "Agentic Dev Resources".

## Architecture & Approach

The workflow uses the official `pre-commit/action@v3.0.1` GitHub Action, which installs pre-commit and runs all hooks against all files — the same checks enforced locally. The workflow triggers on pull requests to `main` and also on pushes to `main` (to keep the status current after merges). It requires only three standard steps: checkout, Python setup, and the pre-commit action itself. No custom scripts or additional tooling are needed since the existing `.pre-commit-config.yaml` defines all hook configuration.

The `jms-plan` skill's research step (Step 2 in `SKILL.md`) currently fetches and reviews individual external references. The enhancement adds three new research dimensions: (1) a compatibility matrix analysing how all chosen components interact with each other, (2) web and GitHub issue searches to surface known integration problems between components, and (3) a licence summary table listing the licence of each external dependency. These additions extend the existing research step and the `research.md` template — no new steps or files are introduced.

The README title change is a straightforward text edit unrelated to the other work but included in the same plan per the prompt.

## Components

### GitHub Actions Workflow

**Purpose:** Run pre-commit hooks in CI as a required status check on pull requests.
**Inputs:** The repository's `.pre-commit-config.yaml` (read by pre-commit at runtime).
**Outputs:** A pass/fail status check on the pull request. Failures block merging when configured as a required status check in GitHub branch protection settings.
**Notes:** The workflow file lives at `.github/workflows/pre-commit.yml`. It runs on `ubuntu-latest` with Python set up via `actions/setup-python`. The `pre-commit/action` automatically caches hook environments for faster subsequent runs. The workflow should target pull requests to `main` and pushes to `main`. Making the check mandatory requires a branch protection rule configured in the GitHub repository settings (outside the scope of this code change, but noted for the user).

### jms-plan Research Enhancement

**Purpose:** Extend the research stage of the `jms-plan` skill to produce deeper analysis of external dependencies — not just individual summaries but cross-component compatibility verification, known-issues discovery, and licence awareness.
**Inputs:** Current `plugins/jinglemansweep/skills/jms-plan/SKILL.md` (Step 2: Research section and the `research.md` template).
**Outputs:** Updated SKILL.md with enhanced research instructions and an expanded `research.md` template.
**Notes:** Three additions to the research step: (1) After documenting individual references, add a **Compatibility Matrix** section that analyses how components interact — version conflicts, overlapping responsibilities, known incompatibilities. (2) For each reference, perform web and GitHub issue searches (e.g. "X + Y issues") to surface real-world integration problems, recording findings under a new **Integration Verification** field per reference. (3) Add a **Licence Summary** table at the end of `research.md` listing each dependency's licence and a brief compatibility note. The existing per-reference structure stays intact; these are additive changes.

### README Title Update

**Purpose:** Rename the project title from "agent-resources" to "Agentic Dev Resources" to better reflect the project's purpose.
**Inputs:** Current `README.md` content.
**Outputs:** Updated `README.md` with new title.
**Notes:** Only the H1 heading text changes. The license badge and all other content remain unchanged.

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `.github/workflows/pre-commit.yml` | Create | GitHub Actions workflow running pre-commit on PRs |
| `plugins/jinglemansweep/skills/jms-plan/SKILL.md` | Modify | Enhance research step with compatibility, issue searches, and licence breakdown |
| `README.md` | Modify | Update H1 title to "Agentic Dev Resources" |
