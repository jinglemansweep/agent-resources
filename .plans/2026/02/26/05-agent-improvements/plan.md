# Implementation Plan

> Source: `.plans/20260226/05-agent-improvements/prompt.md`

## Overview

Update two existing role agents — `jms-role-devops` and `jms-role-frontend` — with more specific, opinionated guidance. The DevOps agent gains expanded Docker best-practice instructions centred on multi-stage builds. The Frontend agent shifts from a generic "match whatever the project uses" posture to a preferred stack of TailwindCSS v4 + DaisyUI + Alpine.js, with mandatory responsive design and light/dark theme requirements.

## Architecture & Approach

Both agents are single Markdown files in `plugins/jinglemansweep/agents/`. The changes are purely documentation — no code, no config files, no dependencies. Each agent's "Domain Expertise" section will be expanded with the new guidance while preserving the existing Quality Gates and Constraints sections unchanged.

For the **DevOps agent**, Docker guidance already exists as a bullet point. This will be expanded into a dedicated Docker subsection with multi-stage build patterns, layer caching strategy, security hardening, and `.dockerignore` expectations.

For the **Frontend agent**, the current generic framework-agnostic stance will be replaced with an explicit preferred stack (Tailwind + DaisyUI + Alpine.js) while still allowing deviation when a project already uses something else. Alpine.js replaces the originally considered Lit due to Shadow DOM friction with Tailwind — Alpine.js uses Light DOM only, making Tailwind utility classes work natively. A new "Responsive & Theming" subsection will codify the light/dark mode and responsive requirements, including the specific DaisyUI `data-theme` pattern for theme toggling.

## Components

### DevOps Agent — Docker Guidance

**Purpose:** Provide specific, actionable Docker best practices so the agent produces production-quality Dockerfiles by default.

**Inputs:** The existing `jms-role-devops.md` agent file.

**Outputs:** Updated agent file with an expanded Docker subsection under Domain Expertise.

**Notes:**
- Multi-stage builds should be the default recommendation where a build step exists (compiled languages, frontend asset builds, etc.)
- Include guidance on: minimal base images (alpine/distroless), layer ordering for cache efficiency, non-root users, `.dockerignore`, `COPY` over `ADD`, pinned base image versions
- Keep the guidance as principles/rules, not code examples — the agent applies them contextually per project

### Frontend Agent — Preferred Stack

**Purpose:** Establish TailwindCSS + DaisyUI + Alpine.js as the default frontend stack, with a philosophy of minimal dependencies over monolithic frameworks.

**Inputs:** The existing `jms-role-frontend.md` agent file.

**Outputs:** Updated agent file with a preferred stack section and updated Domain Expertise.

**Notes:**
- The preferred stack applies when starting new work or when the project has no established frontend framework
- When a project already uses React/Vue/etc., the agent should still follow that project's conventions
- Alpine.js (~14 KB) chosen over Lit because it uses Light DOM only — Tailwind utility classes work natively with no Shadow DOM workarounds
- Include the tooling philosophy: prefer lightweight, low-dependency tools; avoid heavy framework lock-in
- Target Tailwind v4+ (CSS-based configuration)

### Frontend Agent — Responsive & Theming Requirements

**Purpose:** Codify responsive design and light/dark mode as mandatory requirements for all frontend output.

**Inputs:** The existing `jms-role-frontend.md` agent file (same file as above).

**Outputs:** A new "Responsive & Theming" subsection in the agent file.

**Notes:**
- All web content must be responsive (mobile-first approach)
- Dark mode: detect system preference via `prefers-color-scheme`, apply via DaisyUI's `data-theme` attribute on `<html>`
- User overrides stored in localStorage; on page load, check localStorage first, fall back to system preference
- Include this specific pattern in the agent guidance so it can produce working theme toggle implementations

## File Manifest

| File | Action | Purpose |
|------|--------|---------|
| `plugins/jinglemansweep/agents/jms-role-devops.md` | Modify | Expand Docker section with multi-stage build and best-practice guidance |
| `plugins/jinglemansweep/agents/jms-role-frontend.md` | Modify | Add preferred stack, tooling philosophy, responsive/theming requirements |
