## TASK-001: Add tutorial section scaffold and prerequisites to README
**Status:** completed
### Files Modified
- `README.md`
### Notes
Inserted 11 lines between the agentmap plugin section and the Installation section. Added "## Tutorial: Using the jplan Pipeline" heading with introduction and "### Prerequisites" subsection listing Claude Code CLI, git repository, and jplan plugin installation.
---

## TASK-002: Add phase directory structure and pipeline overview to tutorial
**Status:** completed
### Files Modified
- `README.md`
### Notes
Added two subsections after Prerequisites: "### Phase Directory Structure" explaining the .plans/YYYY/MM/DD/NN-slug/ convention with file tree diagram, and "### Pipeline Overview" with an 8-stage table listing all slash commands and their purposes.
---

## TASK-003: Write stage descriptions for setup, plan, and PRD generation
**Status:** completed
### Files Modified
- `README.md`
### Notes
Added "### Step-by-Step Walkthrough" subsection after Pipeline Overview with three stage descriptions (#### Stage 1-3) covering /jp-setup, /jp-plan, and /jp-prd. Each includes command syntax, description, output artifacts, and user interaction notes.
---

## TASK-004: Write stage descriptions for PRD review, task list, and task review
**Status:** completed
### Files Modified
- `README.md`
### Notes
Added Stage 4-6 descriptions covering /jp-prd-review (with PASS/REVISE/ESCALATE verdict explanation), /jp-task-list, and /jp-task-review. Task review references Stage 4 verdict definitions rather than repeating them.
---

## TASK-005: Write stage descriptions for execution and summary
**Status:** completed
### Files Modified
- `README.md`
### Notes
Added Stage 7 (/jp-execute) with delegation to jp-worker-dev, validate-review-fix loop explanation, and domain roles blockquote listing all 6 available roles. Added Stage 8 (/jp-summary) with final report description.
---

## TASK-006: Add /jp-quick quick pipeline reference
**Status:** completed
### Files Modified
- `README.md`
### Notes
Added "### Quick Pipeline (`/jp-quick`)" subsection after Stage 8 with command syntax for new phase and resume usage, plus guidance on when to use /jp-quick vs individual stages.
---

## TASK-007: Verify tutorial accuracy against skill definitions
**Status:** completed
### Files Modified
- `README.md`
### Notes
Cross-referenced all 9 slash commands, artifact names, pipeline order, verdict names, domain role names, and agent name against actual SKILL.md files. Found one inaccuracy: Stage 6 (/jp-task-review) incorrectly claimed ESCALATE as a verdict — the actual skill only uses PASS/REVISE. Fixed Stage 6 description to reflect the correct two-verdict system with expanded definitions.
---

## TASK-008: Run markdownlint and fix any violations
**Status:** completed
### Files Modified
- (none)
### Notes
Ran `pre-commit run markdownlint --files README.md` — passed with no violations. No fixes needed.
---
