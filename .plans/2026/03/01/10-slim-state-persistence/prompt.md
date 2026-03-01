# Phase: 10-slim-state-persistence

* Update "install.sh" scripts to not be backwards compatible, they are for testing, update CLAUDE.md to reflect this
* Restructure individual "plan" (.plans/YYYY/MM/DD/II-description) directory:
  * `task-review.yaml` -> `reviews/tasks.yaml`
  * `prd-review.md` -> `reviews/prd.md`
  * `fix-ledger.yaml` -> `reviews/fixes.yaml`
  * `reviews/round-X.yaml` -> `reviews/cycle/XX.yaml` (`XXX` zero-padded index, e.g. `012.yaml`)
  * `tasks.yaml` -> `tasks.yaml`
  * `prd.md` -> `prd.md`
  * `summary.md` -> `summary.md`
* We are persisting too much state resulting in unncessary tool calls and token wastage:
  * Task logs should become a single appended changelog.md
  * state.yaml should be slimmed to just the fields needed for resumability (status, current phase/task, review-loop counters, per-task pass/fail status).

Logs:

Recommendation: Replace logs/ with a single changelog.md appended to after each task completes. Something like:

Proposed `state.yaml` layout:

What's genuinely useful (keep):
- status, current_phase, current_task — needed for resumability
- fix_round, last_review_round, review_loop_exit_reason — needed for review-loop state
- quality_gate — needed to know if quality gate passed
- Per-task status — needed to know where to resume

```
status: completed          # pending | running | review_loop | completed | failed
phase_path: .plans/2026/03/01/08-fixes-renames
branch: fix/fixes-and-renames
current_phase: completed   # task_execution | review_loop | quality_gate | completed
current_task: null
fix_round: 1
last_review_round: 2
review_loop_exit_reason: success
quality_gate: pass
tasks:
  TASK-001: completed
  TASK-002: completed
  TASK-003: completed
```
