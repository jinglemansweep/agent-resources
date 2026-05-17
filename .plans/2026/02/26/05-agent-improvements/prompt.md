# Agent Improvements

## DevOps Agent (`jms-role-devops`)

Update the DevOps agent with Docker-specific guidance:

- Dockerfiles should use multi-stage builds where appropriate
- Follow Docker best practices (layer caching, minimal base images, .dockerignore, etc.)

## Frontend Agent (`jms-role-frontend`)

Update the Frontend agent with specific technology preferences and standards:

### Preferred Stack

- **CSS Framework:** TailwindCSS
- **UI Components:** DaisyUI (Tailwind plugin)
- **Web Components:** LitJS (Lit elements)
- **Tooling philosophy:** Prefer lightweight tools and dependencies with minimal transitive dependencies over full monolithic JS/TS frameworks

### Responsive & Theming Requirements

- All web content must be fully responsive
- Support light/dark modes automatically based on system preference (`prefers-color-scheme`)
- Allow user overrides stored in browser localStorage
