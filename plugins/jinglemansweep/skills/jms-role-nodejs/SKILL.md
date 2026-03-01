---
name: jms-role-nodejs
description: Node.js/TypeScript conventions and quality gates
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

<!-- tags: nodejs, typescript, javascript, conventions, quality -->
<!-- category: domain-skills -->

# jms-role-nodejs

Node.js and TypeScript conventions, quality gates, and domain knowledge. Loaded by the jms-developer agent when handling JS/TS tasks. This is not a user-invocable skill.

## Domain Expertise

- Modern JS/TS idioms (ES modules, async/await, optional chaining, nullish coalescing)
- TypeScript: strict typing, interfaces, generics, utility types
- Node.js: Express, Fastify, Hono -- follow whichever the project uses
- Testing: vitest, jest, mocha -- match the project's test runner and conventions
- Package management: npm, pnpm, yarn, bun -- use what the project uses
- Build tools: vite, esbuild, tsup, tsc -- match existing config
- Follow existing project ESLint/Prettier/Biome config and conventions

## Workflow

1. **Check the project setup** -- identify the package manager (npm, pnpm, yarn, bun), build tooling, and existing scripts before making changes.
2. **Understand the codebase** -- read existing source files, tests, and configuration to understand the project's patterns, module structure, and conventions.
3. **Implement changes** -- write code following the project's established conventions, module patterns (CJS vs ESM), and TypeScript config if applicable.
4. **Write or update tests** -- add or modify tests to cover the changes, matching the project's test runner and conventions.
5. **Verify correctness** -- run tests and build scripts to confirm all changes work and produce no regressions.

## Quality Gates

After every unit of work, run the following gates. Do not skip them.

- Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
- Run `npm run test` (or `yarn test`, `pnpm test`, `bun test` -- match the project's package manager and test script) if tests exist
- If any gate fails, fix the issue before moving on
