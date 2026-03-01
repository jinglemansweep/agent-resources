# Product Requirements Document

> Source: `.plans/2026/03/01/11-improve-plan-skill/prompt.md`

## Project Overview

The `jp-plan` skill currently creates a phase directory with a blank `prompt.md` template and tells the user to fill it in before running `/jp-prd`. This enhancement adds an interactive review step: after the user has written their prompt content, `jp-plan` reads it back, identifies any obvious gaps or inaccuracies, and conducts a brief interview to resolve them — updating `prompt.md` in place before handing off to the next pipeline stage.

## Goals

- Reduce friction between `/jp-plan` and `/jp-prd` by catching obvious prompt issues early.
- Improve prompt quality without adding a heavy analysis step.
- Keep the interaction lightweight — a quick sanity check, not a detailed requirements review (that is `/jp-prd-review`'s job).

## Functional Requirements

### REQ-001: Prompt Ingestion After User Edits

**Description:** After creating the phase directory and `prompt.md` (current Step 6), the skill must pause for the user to write their prompt content, then read the completed `prompt.md` back into context.

**Acceptance Criteria:**

- [ ] The skill waits for the user to confirm they have finished editing `prompt.md` before proceeding (e.g. via `AskUserQuestion` or detecting user input).
- [ ] The full contents of `prompt.md` are read after the user signals readiness.

### REQ-002: High-Level Prompt Review

**Description:** The skill performs a lightweight scan of the ingested `prompt.md` to identify obvious gaps or inaccuracies. This is explicitly not a detailed analysis — it focuses only on clear omissions or contradictions that would hinder PRD generation.

**Acceptance Criteria:**

- [ ] The review identifies missing sections that are entirely empty (no content beyond the HTML comment placeholder).
- [ ] The review flags obvious contradictions between sections (e.g. a goal that conflicts with an out-of-scope item).
- [ ] The review does NOT perform deep requirements analysis, suggest additional requirements, or question the user's technical decisions.

### REQ-003: Interactive Interview for Gap Resolution

**Description:** If the high-level review identifies gaps or issues, the skill presents them to the user as a brief interview — asking targeted questions to resolve each issue. If no gaps are found, this step is skipped.

**Acceptance Criteria:**

- [ ] Each identified gap is presented as a clear, concise question to the user.
- [ ] The number of questions is kept to a minimum (ideally 1-3, never more than 5).
- [ ] The user can respond with additional context or explicitly dismiss a gap (e.g. "intentionally left blank").
- [ ] If no gaps are found, the skill proceeds directly without interviewing.

### REQ-004: Update prompt.md With Interview Results

**Description:** After the interview, the skill incorporates the user's responses into `prompt.md`, updating the relevant sections in place.

**Acceptance Criteria:**

- [ ] User responses are written into the appropriate sections of `prompt.md`.
- [ ] Existing user-written content is preserved — only gaps are filled or corrections applied.
- [ ] The updated file maintains the same Markdown structure and heading hierarchy.
- [ ] If the user dismissed all gaps (nothing to change), `prompt.md` is not modified.

### REQ-005: Seamless Integration Into Existing Step Sequence

**Description:** The new behaviour is inserted into the existing `jp-plan` step sequence without breaking the current flow. It occurs after directory/file creation and before the final report.

**Acceptance Criteria:**

- [ ] All existing steps (0-8) continue to function as before.
- [ ] The new prompt review step is clearly documented in the skill's instruction sequence.
- [ ] The final report (current Step 8) still includes all existing information plus a note about any prompt updates made.

## Non-Functional Requirements

### REQ-006: Interaction Brevity

**Category:** Maintainability

**Description:** The interview step must remain lightweight and fast. It should not feel like a second requirements-gathering session.

**Acceptance Criteria:**

- [ ] The entire review-and-interview interaction completes in a single conversational exchange (one round of questions, one round of answers) unless the user initiates follow-up.

## Technical Constraints and Assumptions

### Constraints

- The implementation is a modification to the existing `SKILL.md` file at `plugins/jplan/skills/jp-plan/SKILL.md`.
- Must use only tools already in the skill's `allowed-tools` list: `AskUserQuestion`, `Bash`, `Glob`, `Read`, `Write`.
- Must use the `Edit` tool for updating `prompt.md` (requires adding `Edit` to `allowed-tools`).

### Assumptions

- Users will write meaningful content into `prompt.md` before signalling readiness. The skill does not validate content quality beyond checking for empty sections.
- The existing prompt template sections (Overview, Goals, Requirements, Constraints, Out of Scope, References) are sufficient for the high-level review.

## Scope

### In Scope

- Adding a new step to `jp-plan` that reads, reviews, interviews, and updates `prompt.md`.
- Adding `Edit` to the skill's `allowed-tools` if needed for in-place updates.
- Updating the skill's step numbering and report step to reflect the new behaviour.

### Out of Scope

- Changing the `prompt.md` template structure or sections.
- Detailed requirements analysis (that is `/jp-prd`'s responsibility).
- Modifications to any other skills in the pipeline.
- Changes to `state.yaml` schema or content.

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Skill definition | Markdown (SKILL.md) | Specified by prompt — all skills are single SKILL.md files |
| Interaction | AskUserQuestion tool | Already in allowed-tools, used for interview questions |
| File updates | Edit tool | Needed for in-place `prompt.md` modifications |
