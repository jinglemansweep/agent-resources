# Task List

> Source: `.plans/20260226/08-github-ci-action/plan.md`

## GitHub Actions Workflow

- [x] **Create `.github/workflows/pre-commit.yml`** — Create the workflow file with the following configuration:
  - `name: pre-commit`
  - Triggers: `on.pull_request.branches: [main]` and `on.push.branches: [main]`
  - Single job `pre-commit` running on `ubuntu-latest`
  - Step 1: `uses: actions/checkout@v4`
  - Step 2: `uses: actions/setup-python@v5` with `python-version: '3.x'`
  - Step 3: `uses: pre-commit/action@v3.0.1`
  - No additional inputs or custom scripts are needed — the action reads `.pre-commit-config.yaml` automatically and caches hook environments.
  - Verify: confirm the YAML is valid by checking it with `python -c "import yaml; yaml.safe_load(open('.github/workflows/pre-commit.yml'))"` or equivalent.
  - Note: making this a mandatory status check requires configuring a branch protection rule in the GitHub repo settings after the workflow is merged. Include a reminder about this in the PR description.

## jms-plan Research Enhancement

### Compatibility Matrix

- [x] **Add Compatibility Matrix instructions to Step 2 of `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — After the existing per-reference research loop (the numbered list ending with "Record findings"), add a new paragraph instructing the agent to analyse cross-component compatibility. The instruction should direct the agent to: identify how the researched components interact with each other, check for version conflicts or overlapping responsibilities, note any known incompatibilities, and record findings in a **Compatibility Matrix** section in `research.md`. This goes after the per-reference instructions but before the "If the prompt contains no external references" paragraph.

- [x] **Add Compatibility Matrix section to the `research.md` template in `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — Inside the `research.md` template code block (after the per-reference `## ...` entries and before the closing code fence), add:
  ```
  ## Compatibility Matrix
  <!-- Analyse how the components above interact with each other.
       Note version conflicts, overlapping responsibilities,
       and known incompatibilities. -->
  | Component A | Component B | Status | Notes |
  |-------------|-------------|--------|-------|
  | ... | ... | Compatible / Conflict / Unknown | ... |
  ```

### Integration Verification

- [x] **Add Integration Verification instructions to Step 2 of `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — Within the per-reference research loop (after the existing sub-items under "Fetch and review"), add a new sub-item: "Perform web and GitHub issue searches (e.g. `<component> + <other component> issues`) to surface known real-world integration problems. Record findings under an **Integration Verification** field for each reference."

- [x] **Add Integration Verification field to the per-reference template in `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — In the `research.md` template code block, add a new field `- **Integration Verification:** <results of web/GitHub issue searches for known integration problems>` to the per-reference entry, after the `**Concerns:**` field.

### Licence Summary

- [x] **Add Licence Summary instructions to Step 2 of `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — After the Compatibility Matrix instructions (added above), add a paragraph instructing the agent to compile a licence summary table listing each external dependency's licence type and a brief compatibility note. This should be recorded in a **Licence Summary** section at the end of `research.md`.

- [x] **Add Licence Summary section to the `research.md` template in `plugins/jinglemansweep/skills/jms-plan/SKILL.md`** — Inside the `research.md` template code block, after the Compatibility Matrix section, add:
  ```
  ## Licence Summary
  | Dependency | Licence | Compatibility Notes |
  |------------|---------|---------------------|
  | ... | ... | ... |
  ```

## README Update

- [x] **Update the H1 title in `README.md`** — Change line 1 from `# agent-resources` to `# Agentic Dev Resources`. No other content in the file should change. Verify by reading the first line of the file after the edit.
