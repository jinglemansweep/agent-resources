# Issues

> Source: `.plans/20260226/06-docs-role-improvements/prompt.md`

## Open Questions

- No open questions — the scope is clear and the referenced skill provides concrete guidance.

## Potential Blockers

- No potential blockers identified.

## Risks

- [RESOLVED] **Over-prescriptive workflow:** If the workflow steps are too rigid, they may not suit all project types (e.g. projects with no tests, or non-Node stacks). → **Decision:** Use guidance-oriented steps — each step described as a principle with brief explanation, agent adapts to the project. No hardcoded commands or checklists.

## Future Considerations

- [RESOLVED] Other role agents could benefit from similar workflow sections (e.g. a testing workflow for `jms-role-python`). This change could serve as a template. → **Decision:** Add workflow sections to ALL role agents now, not as future work. Each agent gets a domain-appropriate workflow tailored to its specialty.
- [RESOLVED] If the docs agent is used in a team context, the summary step could be formalised as a structured output (e.g. a changelog diff) rather than free-form prose. → **Decision:** Use structured list format — agent reports changes categorised as added, removed, and corrected. Apply this pattern to summary/reporting steps in all agents where applicable.
