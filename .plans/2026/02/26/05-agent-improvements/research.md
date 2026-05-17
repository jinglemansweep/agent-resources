# Research

> Source: `.plans/20260226/05-agent-improvements/prompt.md`

## TailwindCSS
- **URL:** https://tailwindcss.com/
- **Status:** Actively maintained
- **Latest Version:** 4.2.1 (February 2026)
- **Compatibility:** Widely supported; requires modern browsers (Safari 16.4+, Chrome 111+, Firefox 128+)
- **Key Findings:**
  - v4 is a major rewrite with CSS-based configuration (replaces `tailwind.config.js`)
  - Significantly faster builds (5x full, 100x+ incremental)
  - PostCSS plugin moved to `@tailwindcss/postcss`
  - Built-in dark mode support via `prefers-color-scheme` and class-based toggling
- **Concerns:** Plugin ecosystem still catching up to v4 architecture changes; some v3 plugins need updates

## DaisyUI
- **URL:** https://daisyui.com/
- **Status:** Actively maintained
- **Latest Version:** 5.5.19 (February 2026)
- **Compatibility:** DaisyUI 5.x is fully compatible with Tailwind CSS v4
- **Key Findings:**
  - 30+ ready-to-use UI components
  - Built-in theme system with multiple pre-built themes including light/dark
  - Works as a Tailwind plugin — minimal overhead
  - v5 has breaking changes from v4 (config approach changed for Tailwind v4 compatibility)
- **Concerns:** v4→v5 upgrade path requires config changes; depends on Tailwind v4 architecture

## Lit (LitJS)
- **URL:** https://lit.dev/
- **Status:** Actively maintained (OpenJS Foundation)
- **Latest Version:** 3.3.1 (July 2025)
- **Compatibility:** Framework-agnostic web components; works alongside Tailwind/DaisyUI
- **Key Findings:**
  - Lightweight web components library with reactive state and declarative templates
  - Scoped CSS via Shadow DOM
  - Minimal boilerplate; small bundle size
  - Interoperable with any framework or no framework
- **Concerns:** Shadow DOM encapsulation can complicate Tailwind utility class usage (requires `adoptedStyleSheets` or CSS injection patterns); SSR support is limited compared to framework-specific solutions
- **Decision:** Replaced by Alpine.js in the preferred stack due to Shadow DOM friction with Tailwind.

## Alpine.js
- **URL:** https://alpinejs.dev/
- **Status:** Actively maintained
- **Latest Version:** Current stable (2025)
- **Compatibility:** Pure Light DOM — works natively with TailwindCSS utility classes; no Shadow DOM friction
- **Key Findings:**
  - ~14 KB bundle, minimal dependencies
  - Declarative behaviour sprinkled directly on HTML attributes (`x-data`, `x-show`, `x-bind`, etc.)
  - Often called "Tailwind for JavaScript" due to its utility-first HTML-centric approach
  - No build step required; works via CDN or npm
  - Component ecosystem available (Pines UI for Alpine + Tailwind)
- **Concerns:** Not a web component framework — components are HTML patterns, not encapsulated custom elements. Suitable for progressive enhancement but not for building reusable component libraries that ship as standalone packages.
