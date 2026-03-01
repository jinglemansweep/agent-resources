---
name: jms-role-devops
description: Infrastructure and CI/CD conventions and quality gates
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

<!-- tags: devops, docker, ci, cd, infrastructure, conventions, quality -->
<!-- category: domain-skills -->

# jms-role-devops

Infrastructure and CI/CD conventions, quality gates, and domain knowledge. Loaded by the jms-developer agent when handling DevOps tasks. This is not a user-invocable skill.

## Domain Expertise

### Docker

- Multi-stage builds are the default pattern whenever a build step exists (compiled languages, frontend asset builds, TypeScript compilation). Separate build-time dependencies from the final runtime image. Name stages explicitly (e.g. `FROM node:22-alpine AS build`).
- Use minimal base images: prefer `alpine` variants or `distroless` images for production stages. Always pin base image versions with specific tags (e.g. `node:22-alpine`, not `node:latest`).
- Order Dockerfile instructions for optimal layer caching: copy dependency manifests (`package.json`, `requirements.txt`, `go.mod`) and install dependencies before copying source code, so dependency layers are cached across builds.
- Run containers as a non-root user (use the `USER` directive). Avoid `ADD` in favour of `COPY` (unless extracting archives). Never store secrets in image layers.
- Every project with a Dockerfile must have a `.dockerignore` that excludes `.git/`, `node_modules/`, build artifacts, and other files not needed at runtime.
- Prefer `COPY` over `ADD`. Use `HEALTHCHECK` directives for production images. Keep the number of layers minimal by combining related `RUN` commands.

### CI/CD

- GitHub Actions, GitLab CI -- match the project's platform
- Follow existing workflow/pipeline structure and naming conventions

### Infrastructure as Code

- Terraform, Ansible, Pulumi -- follow whichever the project uses

### Shell Scripting

- Bash best practices: `set -euo pipefail`, proper quoting, error handling
- Use `shellcheck` for validation

### General

- Environment management: .env files, secrets, config layering
- Deployment patterns: blue-green, rolling updates, health checks

## Workflow

1. **Review existing infrastructure** -- read existing pipelines, Dockerfiles, IaC configs, and deployment scripts to understand the current setup before making changes.
2. **Understand the deployment context** -- identify the target platform, environment layering, and any secrets or config management patterns in use.
3. **Implement changes** -- modify or create infrastructure code following existing patterns, naming conventions, and the project's IaC tooling.
4. **Validate configurations** -- run domain-specific validation tools (e.g. `terraform validate`, `shellcheck`, `ansible-lint`) to catch errors before deployment.
5. **Verify** -- confirm the changes work as expected (successful builds, valid configs, passing checks).

## Quality Gates

After every unit of work, run the following gates. Do not skip them.

- Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
- For Terraform projects: run `terraform validate` and `terraform fmt -check`
- For Ansible projects: run `ansible-lint` if available
- For shell scripts: run `shellcheck` if available
- If any gate fails, fix the issue before moving on
