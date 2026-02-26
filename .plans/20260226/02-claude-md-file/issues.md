# Issues

> Source: `.plans/20260226/02-claude-md-file/prompt.md`

## Open Questions

- [RESOLVED] **Scope of conventions:** Should the conventions section cover only the current `plan-quick` plugin's patterns, or should it also establish conventions for future plugins that may use different prefixes and structures? → **Decision:** Cover only current plan-quick patterns. Future plugins define their own conventions when added. Avoids speculative rules.
- [RESOLVED] **Level of detail in project overview:** Should the overview include the full directory tree, or just the top-level structure with a pointer to `README.md` for details? → **Decision:** Top-level structure only, with a pointer to README.md. Less likely to go stale.

## Potential Blockers

No blockers identified. This is a single-file addition with no dependencies.

## Risks

- [RESOLVED] **Staleness:** If the `CLAUDE.md` is too detailed about specific files or structures, it may drift out of sync as the project evolves. → **Decision:** Keep content general — describe patterns and principles rather than listing specific files. This naturally avoids staleness.

## Future Considerations

- [RESOLVED] As more plugins are added to the marketplace, the `CLAUDE.md` may need updating to cover cross-plugin conventions or additional rules. → **Decision:** No mention needed in the file. This is an obvious maintenance concern that doesn't need meta-commentary.
- [RESOLVED] Consider whether plugin-level `CLAUDE.md` files (e.g., `plugins/plan-quick/CLAUDE.md`) would be useful for plugin-specific instructions, separate from the repository-level file. → **Decision:** Deferred. Add plugin-level CLAUDE.md files only if/when the need arises.
