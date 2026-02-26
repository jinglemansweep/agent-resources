# Task List

> Source: `.plans/20260226/05-agent-improvements/plan.md`

## DevOps Agent — Docker Guidance

### Expand Docker Best Practices

- [x] **Add Docker Best Practices subsection to DevOps agent** — In `plugins/jinglemansweep/agents/jms-role-devops.md`, replace the existing single Docker bullet point (`- Docker: Dockerfiles, multi-stage builds, docker-compose, best practices (minimal layers, non-root users)`) in the Domain Expertise section with an expanded Docker subsection. Keep all other Domain Expertise bullets unchanged. The new subsection should be structured as `### Docker` under Domain Expertise and contain the following rules:
  - [x] **Multi-stage builds** — Add guidance that multi-stage builds are the default pattern whenever a build step exists (compiled languages, frontend asset builds, TypeScript compilation). Separate build-time dependencies from the final runtime image. Name stages explicitly (e.g. `FROM node:22-alpine AS build`).
  - [x] **Base images** — Add guidance to use minimal base images: prefer `alpine` variants or `distroless` images for production stages. Always pin base image versions with specific tags (e.g. `node:22-alpine`, not `node:latest`).
  - [x] **Layer caching** — Add guidance on ordering Dockerfile instructions for optimal layer caching: copy dependency manifests (`package.json`, `requirements.txt`, `go.mod`) and install dependencies before copying source code, so dependency layers are cached across builds.
  - [x] **Security** — Add guidance to run containers as a non-root user (use `USER` directive), avoid `ADD` in favour of `COPY` (unless extracting archives), and never store secrets in image layers.
  - [x] **`.dockerignore`** — Add guidance that every project with a Dockerfile must have a `.dockerignore` that excludes `.git/`, `node_modules/`, build artifacts, and other files not needed at runtime.
  - [x] **General Docker rules** — Add guidance to prefer `COPY` over `ADD`, use `HEALTHCHECK` directives for production images, and keep the number of layers minimal by combining related `RUN` commands.

## Frontend Agent — Preferred Stack & Philosophy

### Add Preferred Stack Section

- [x] **Add Preferred Stack subsection to Frontend agent** — In `plugins/jinglemansweep/agents/jms-role-frontend.md`, add a new `### Preferred Stack` subsection inside the Domain Expertise section, positioned after the existing bullets. This subsection defines the default technologies for new frontend work. Include the following:
  - [x] **TailwindCSS v4+** — Specify TailwindCSS as the preferred CSS framework. Note that v4 uses CSS-based configuration (no `tailwind.config.js`). The PostCSS plugin is `@tailwindcss/postcss`.
  - [x] **DaisyUI** — Specify DaisyUI as the preferred component library. It provides 30+ ready-to-use UI components as a Tailwind plugin with minimal overhead. Use DaisyUI v5.x which is compatible with Tailwind v4.
  - [x] **Alpine.js** — Specify Alpine.js as the preferred JavaScript behaviour layer for interactivity. It is ~14 KB, uses Light DOM only (no Shadow DOM friction with Tailwind), requires no build step, and is declarative via HTML attributes (`x-data`, `x-show`, `x-bind`). Note that Alpine.js is preferred over web component libraries like Lit because Tailwind utility classes work natively without Shadow DOM workarounds.
  - [x] **Fallback rule** — Add a clear rule: the preferred stack applies when starting new work or when the project has no established frontend framework. When a project already uses React, Vue, Svelte, or another framework, follow that project's conventions instead.

### Add Tooling Philosophy

- [x] **Add Tooling Philosophy subsection to Frontend agent** — In `plugins/jinglemansweep/agents/jms-role-frontend.md`, add a `### Tooling Philosophy` subsection inside the Domain Expertise section, after the Preferred Stack subsection. Include the following principles:
  - Prefer lightweight tools and dependencies with minimal transitive dependencies
  - Avoid heavy framework lock-in and monolithic JS/TS frameworks when simpler alternatives exist
  - Choose tools that compose well together over all-in-one solutions

### Update Existing Domain Expertise Bullets

- [x] **Update component frameworks bullet** — In `plugins/jinglemansweep/agents/jms-role-frontend.md`, update the first bullet in Domain Expertise from `- Component frameworks: React, Vue, Svelte, Angular — follow whichever the project uses` to `- Component frameworks: Alpine.js preferred for new projects; React, Vue, Svelte, Angular — follow whichever an existing project uses`. This reflects the new preferred stack while preserving the fallback.
- [x] **Update styling bullet** — In `plugins/jinglemansweep/agents/jms-role-frontend.md`, update the styling bullet from `- Styling: CSS, Tailwind, CSS Modules, styled-components — match the project's approach` to `- Styling: TailwindCSS v4 + DaisyUI preferred for new projects; match the project's existing approach otherwise`. This reflects the new preferred stack.

## Frontend Agent — Responsive & Theming Requirements

### Add Responsive & Theming Subsection

- [x] **Add Responsive & Theming subsection to Frontend agent** — In `plugins/jinglemansweep/agents/jms-role-frontend.md`, add a new `### Responsive & Theming` subsection inside the Domain Expertise section, after the Tooling Philosophy subsection. Include the following mandatory requirements:
  - [x] **Responsive design** — All web content must be fully responsive using a mobile-first approach. Use Tailwind's responsive breakpoint prefixes (`sm:`, `md:`, `lg:`, `xl:`) to adapt layouts.
  - [x] **Dark mode detection** — Detect system colour scheme preference via CSS `prefers-color-scheme` media query.
  - [x] **DaisyUI theme toggling** — Apply themes using DaisyUI's `data-theme` attribute on the `<html>` element (e.g. `<html data-theme="light">` or `<html data-theme="dark">`).
  - [x] **User override persistence** — Store the user's theme preference in `localStorage`. On page load, check `localStorage` first; if no stored preference, fall back to the system `prefers-color-scheme` value. Update `localStorage` whenever the user explicitly toggles the theme.
  - [x] **Light and dark as minimum** — Every project must support at least `light` and `dark` themes. Additional DaisyUI themes may be added as needed.
