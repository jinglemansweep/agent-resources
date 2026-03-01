---
name: jms-role-frontend
description: Frontend/UI conventions and quality gates
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

<!-- tags: frontend, ui, css, html, react, tailwind, conventions, quality -->
<!-- category: domain-skills -->

# jms-role-frontend

Frontend and UI conventions, quality gates, and domain knowledge. Loaded by the jms-developer agent when handling frontend tasks. This is not a user-invocable skill.

## Domain Expertise

- Component frameworks: Alpine.js preferred for new projects; React, Vue, Svelte, Angular -- follow whichever an existing project uses
- Styling: TailwindCSS v4 + DaisyUI preferred for new projects; match the project's existing approach otherwise
- State management: match existing patterns (Redux, Zustand, Pinia, Context, signals)
- Accessibility: semantic HTML, ARIA attributes, keyboard navigation
- Responsive design and mobile-first patterns
- JSX/TSX conventions, component composition, prop patterns
- Follow existing component directory structure and naming conventions

## Preferred Stack

The following stack is the default for new frontend work or projects with no established framework. When a project already uses React, Vue, Svelte, or another framework, follow that project's conventions instead.

- **TailwindCSS v4+** -- Preferred CSS framework. v4 uses CSS-based configuration (no `tailwind.config.js`). The PostCSS plugin is `@tailwindcss/postcss`.
- **DaisyUI** -- Preferred component library. Provides 30+ ready-to-use UI components as a Tailwind plugin with minimal overhead. Use DaisyUI v5.x, which is compatible with Tailwind v4.
- **Alpine.js** -- Preferred JavaScript behaviour layer for interactivity. ~14 KB, Light DOM only (no Shadow DOM friction with Tailwind), no build step required, declarative via HTML attributes (`x-data`, `x-show`, `x-bind`). Preferred over web component libraries like Lit because Tailwind utility classes work natively without Shadow DOM workarounds.

## Tooling Philosophy

- Prefer lightweight tools and dependencies with minimal transitive dependencies
- Avoid heavy framework lock-in and monolithic JS/TS frameworks when simpler alternatives exist
- Choose tools that compose well together over all-in-one solutions

## Responsive and Theming

- **Responsive design** -- All web content must be fully responsive using a mobile-first approach. Use Tailwind's responsive breakpoint prefixes (`sm:`, `md:`, `lg:`, `xl:`) to adapt layouts.
- **Dark mode detection** -- Detect system colour scheme preference via the CSS `prefers-color-scheme` media query.
- **DaisyUI theme toggling** -- Apply themes using DaisyUI's `data-theme` attribute on the `<html>` element (e.g. `<html data-theme="light">` or `<html data-theme="dark">`).
- **User override persistence** -- Store the user's theme preference in `localStorage`. On page load, check `localStorage` first; if no stored preference, fall back to the system `prefers-color-scheme` value. Update `localStorage` whenever the user explicitly toggles the theme.
- **Light and dark as minimum** -- Every project must support at least `light` and `dark` themes. Additional DaisyUI themes may be added as needed.

## Workflow

1. **Understand the component structure** -- review existing components, the design system, and UI patterns to understand the project's conventions before creating anything new. Check the Preferred Stack and Responsive and Theming sections for defaults.
2. **Implement changes** -- build or modify components following existing patterns, composition style, and naming conventions. Use the project's established framework and styling approach.
3. **Ensure responsiveness and theming** -- verify the implementation works across breakpoints using a mobile-first approach and supports the project's theme system (light/dark as minimum).
4. **Check accessibility** -- confirm semantic HTML, appropriate ARIA attributes, and keyboard navigation.
5. **Verify the build** -- run tests and build scripts to confirm no breakage.

## Quality Gates

After every unit of work, run the following gates. Do not skip them.

- Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
- Run `npm run test` (or equivalent, matching the project's package manager) if tests exist
- Run `npm run build` (or equivalent) to verify no build breakage
- If any gate fails, fix the issue before moving on
