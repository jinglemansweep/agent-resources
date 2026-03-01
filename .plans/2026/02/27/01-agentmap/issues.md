# Issues

> Source: `.plans/20260227/01-agentmap/prompt.md`

## Open Questions

- [RESOLVED] **Plugin vs standalone delivery**: The prompt describes the deliverable as `agentmap/` with skill subdirectories directly inside it, ready to copy into `.claude/skills/`. The plan places it under `plugins/agentmap/skills/` to match this repo's convention. → **Decision:** Use the plugin convention (`plugins/agentmap/skills/`). Matches existing repo structure and integrates with the marketplace/install system. Installed result is identical either way.
- [RESOLVED] **Example project choice**: The prompt suggests "the melabasco example works well" — this appears to reference a prior design session. → **Decision:** Use a fictional but realistic project (e.g. Flask/FastAPI web app with CLI tooling). Avoids coupling to external references that may change or be unfamiliar to readers.

## Potential Blockers

- None identified. All deliverables are self-contained markdown and YAML with no external dependencies.

## Risks

- [RESOLVED] **Token budget for read skill**: The 250-token cap is tight. Covering all six schema sections with one-line descriptions, plus staleness warning and routing-table caveat, requires very precise writing. → **Decision:** Strict 250-token cap enforced. Iterate during implementation until it fits — cut to fragments, merge related sections, or remove least essential guidance. The cap is the point.
- [RESOLVED] **Reconnaissance completeness vs skill size**: The generate skill's reconnaissance step must cover many ecosystems without becoming unwieldy. → **Decision:** Cover the top ~10 ecosystems explicitly (Python, Node, Rust, Go, Java, C#, Ruby, Elixir, C/C++, generic Make) with specific reconnaissance commands. Use generic heuristics as fallback for unknown ecosystems. Longer but reliable.

## Future Considerations

- [RESOLVED] **Schema version evolution**: Version 1 is specified. A future version 2 migration path isn't needed now but the `version` field exists to support it. → **Decision:** Add a minimal one-line version note in the read skill: "Check version field; this skill covers v1." Low cost, provides forward-compatibility hint.
- [RESOLVED] **Skill discoverability**: Currently skills are loaded by explicit CLAUDE.md directives or slash-command invocation. → **Decision:** Add structured metadata comments (tags, categories) to SKILL.md files as forward-compatible hints for potential future auto-discovery features.
- [RESOLVED] **Sub-maps complexity**: The `sub_maps` section for monorepos is specified but may need real-world validation. → **Decision:** Include sub_maps in the schema and example, but mark it as experimental with a note that it's less battle-tested than the core sections. Ship it, validate with real-world usage later.
