# Issues

> Source: `.plans/20260226/05-agent-improvements/prompt.md`

## Open Questions

- No open questions — the prompt is clear on technologies and requirements.

## Potential Blockers

- No blockers — changes are documentation-only modifications to existing agent files.

## Risks

- [RESOLVED] **Lit + Tailwind Shadow DOM friction:** Tailwind utility classes don't naturally penetrate Shadow DOM boundaries. The agent guidance should acknowledge this and recommend patterns like `adoptedStyleSheets` or Tailwind's `@apply` within component styles. If this isn't addressed, the agent may produce components where Tailwind classes silently fail. → **Decision:** Replace Lit with Alpine.js in the preferred stack. Alpine.js uses Light DOM only, eliminating Shadow DOM friction entirely. It pairs naturally with Tailwind utility classes and aligns with the minimal-dependency philosophy (~14 KB).

## Future Considerations

- [RESOLVED] **Tailwind v4 config migration:** Tailwind v4 uses CSS-based configuration instead of `tailwind.config.js`. If the agent encounters older projects still on v3, the guidance may not fully apply. Consider noting version-awareness in a future update. → **Decision:** Target Tailwind v4 only. Older v3 projects are handled by the existing "follow project conventions" fallback. No version-awareness guidance needed.
- [RESOLVED] **DaisyUI theme overrides and localStorage:** The prompt specifies localStorage for user theme preference. DaisyUI supports this via `data-theme` on `<html>`, but the agent will need to know this pattern to implement it correctly. The guidance should be specific enough that the agent can produce working theme toggle code. → **Decision:** Include the specific DaisyUI pattern in the agent: use `data-theme` attribute on `<html>`, detect system preference with `prefers-color-scheme`, store user override in localStorage.
