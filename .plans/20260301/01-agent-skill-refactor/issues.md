# Issues

> Source: `.plans/20260301/01-agent-skill-refactor/prompt.md`

## Open Questions

- [RESOLVED] **Phase directory format — breaking change.** The prompt specifies `YYYY/MM/DD/NN-slug` (nested) but the current system uses `YYYYMMDD/NN-slug` (flat). This is a breaking change — existing phases created with the flat format won't be found by skills expecting the nested format. Should the new skills support both formats (with fallback detection), or is a clean break acceptable given that no long-lived phases exist? → **Decision:** Clean break to nested format. No backward compatibility. Existing phases are ephemeral and don't need preserving.

- [RESOLVED] **Skill naming for Task Breakdown.** The prompt calls this skill "Task Breakdown" but the current skill is named `jms-taskify`. Should it keep the name `jms-taskify` (maintaining backward compatibility and brevity) or be renamed to `jms-task-breakdown` (matching the prompt's terminology)? → **Decision:** Rename to `jms-task-breakdown`. Matches the prompt's terminology. All references (jms-planner agent, docs, plugin.json) must be updated.

- [RESOLVED] **Research and issues workflow.** The current `jms-plan` generates three files (`research.md`, `plan.md`, `issues.md`) with detailed external reference research, compatibility matrices, and issue tracking. The prompt's Plan skill generates a single `prd.md` with requirements and acceptance criteria. This removes the research and issues workflow entirely. Is this intentional, or should the research/issues steps be preserved as a separate skill or incorporated into the PRD generation? → **Decision:** Single prd.md as specified in the prompt. Requirements-first approach replaces the research/issues workflow. The PRD Review skill covers quality assurance.

- [RESOLVED] **Sub-skills vs embedded logic in Execute.** The prompt defines Validate, Code Review, Fix, and Summary as separate "skills" (sections 8-11) but they appear to be invoked only by the Execute orchestrator, never directly by the user. Should these be implemented as separate SKILL.md files (user-invocable but primarily used by the orchestrator), or should their logic be embedded entirely within the Execute SKILL.md? → **Decision:** Separate SKILL.md files. Each sub-stage gets its own skill for clean separation of concerns, independent testability, and ad-hoc manual use. Execute references them by name.

- [RESOLVED] **jms-executor agent.** The existing system has a `jms-executor` agent type registered in the Task tool's subagent list. The prompt's Execute skill delegates to role agents but doesn't mention a dedicated executor agent. Should `jms-executor` be updated or is it now superseded by the Execute skill itself? → **Decision:** Remove jms-executor agent. The Execute skill is the orchestrator now; the agent is redundant. Remove from agents directory and any registrations.

## Potential Blockers

- None identified. All changes are to Markdown skill/agent definition files within the existing plugin structure. No external dependencies, build systems, or runtime changes are required.

## Risks

- [RESOLVED] **Execute skill complexity.** The rewritten Execute skill is substantially more complex than the current version — it must manage state.yaml, delegate to role agents, run validation, orchestrate the review & fix loop (with regression detection and iteration limits), maintain the fix ledger, and generate a summary. This is a lot of logic for a single SKILL.md prompt. If Claude struggles to follow all instructions reliably in a single context, the skill may need to be decomposed further. → **Decision:** Accept complexity, rely on sub-skills. Since Validate, Code Review, Fix, and Summary are separate SKILL.md files, Execute just orchestrates them, reducing its cognitive load. Revisit if performance issues arise.

- [RESOLVED] **state.yaml consistency.** The state.yaml mechanism assumes the orchestrator will reliably update it after every state change. If a session is interrupted mid-update (e.g. between completing a task and writing state), the state file could be inconsistent. There is no corruption detection or recovery mechanism specified. → **Decision:** Accept risk, no recovery mechanism for v1. Sessions rarely crash mid-YAML-write. If state.yaml is corrupted, the user can delete it and re-run.

- [RESOLVED] **tasks.yaml parsing.** The current system uses markdown checkboxes (`- [ ]` / `- [x]`) which are trivially parseable by an LLM. Switching to structured YAML with nested fields (dependencies, acceptance criteria, files_affected) requires the LLM to reliably parse and generate valid YAML. YAML is sensitive to indentation errors. → **Decision:** Use YAML, accept the risk. LLMs handle YAML well in practice. Include a clear schema example in the SKILL.md for reference.

## Future Considerations

- [RESOLVED] **Parallel task execution.** The prompt mentions "parallelise independent tasks where possible" in the Execute spec. The current Claude Code Task tool supports spawning parallel agents. However, managing concurrent state updates to `state.yaml` and `tasks.yaml` from multiple parallel agents is non-trivial and not addressed in the prompt. This may need explicit design if parallel execution is pursued. → **Decision:** Defer to future. Process tasks sequentially in v1. Note as a future enhancement to avoid concurrent state management complexity.

- [RESOLVED] **Pipeline composition.** Once the skill set stabilizes, it may be worth creating a top-level orchestrator skill that runs the entire pipeline (phase → plan → review → taskify → task-review → execute) in sequence, reducing the number of manual skill invocations the user must make. → **Decision:** Defer entirely. Get individual skills working first. A meta-orchestrator can be added later once the pipeline is proven.

- [RESOLVED] **Versioning and migration.** If the phase directory format changes (flat → nested dates), existing planning artifacts won't be discoverable. A migration script or dual-format detection could be added later if needed. → **Decision:** No migration needed. Phase directories are ephemeral planning artifacts with no long-lived phases to preserve. Clean break is fine.
