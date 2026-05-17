# Issues

> Source: `.plans/20260226/04-role-agents/prompt.md`

## Open Questions

- No open questions — requirements are clear and self-contained.

## Potential Blockers

- [RESOLVED] **Quality gate constraint conflict**: The current agent explicitly says "Do NOT run quality gates — the caller handles that." The new requirements mandate the opposite. → **Decision:** Both the agent and the executor may run quality gates. Duplicate runs are acceptable — better safe than sorry. Remove the old "Do NOT run quality gates" constraint from all role agents and replace with mandatory quality gate execution.

## Risks

- [RESOLVED] **Agent-run quality gates in team/executor context**: When the Python role agent is spawned by `jms-executor`, the executor may also run quality gates after the agent finishes. → **Decision:** Duplicate runs are explicitly acceptable. No mitigation needed.

## Future Considerations

- [RESOLVED] The same mandatory virtualenv/quality-gate pattern could be applied to other role agents. → **Decision:** All role agents will get mandatory quality gates in this plan. Shared gates (`pre-commit`) apply to all roles. Each role gets additional domain-specific gates: Python (`pytest`), Node.js (`npm run test`), DevOps (`terraform validate`), etc.
- [RESOLVED] The recommended packages list may evolve. → **Decision:** Keep the package list directly in the agent definition file. Simple, self-contained, easy to maintain.
