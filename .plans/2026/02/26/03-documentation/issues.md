# Issues

> Source: `.plans/20260226/03-documentation/prompt.md`

## Open Questions

- [RESOLVED] The `marketplace.json` description says "Plan, Research, Taskify and Execute" while `plugin.json` says "Plan, Review, Taskify and Execute". Should `marketplace.json` also be corrected to say "Review", or is "Research" intentional there? (This is outside the stated scope of README/CLAUDE.md but worth flagging.) → **Decision:** Update the `marketplace.json` description to something more general: "Personal Skills and Agents". Also update `plugin.json` description to match. This avoids listing individual skill names in metadata descriptions, which go stale. Adds `marketplace.json` and `plugin.json` to scope.

## Potential Blockers

- No blockers identified.

## Risks

- No significant risks — these are documentation-only changes.

## Future Considerations

- [RESOLVED] As more plugins or agents are added, the README directory tree and agents list will drift again. Consider whether the README should be auto-generated or kept manually updated. → **Decision:** Keep manual maintenance, but add a convention note to `CLAUDE.md` reminding that README.md must be updated when skills or agents are added/removed/renamed.
