---
name: docs-writer
description: Generates, formats, and validates technical documentation — including docstrings, OpenAPI/Swagger specs, JSDoc annotations, doc portals, and user guides. Ensures README.md, AGENTS.md and other markdown documentation accurately reflects the current state of the project codebase. Use when adding docstrings to functions or classes, creating API documentation, building documentation sites, writing tutorials and user guides, or synchronizing documentation with codebase changes.
license: GPL-3
compatibility: opencode
metadata:
  author: https://github.com/jinglemansweep
  version: "0.2.0"
  domain: quality
  triggers: documentation, docstrings, OpenAPI, Swagger, JSDoc, comments, API docs, tutorials, user guides, doc site, README, AGENTS, markdown, sync docs
  role: specialist
  scope: implementation
  output-format: code
  related-skills: code-review
---

# Docs Writer

Documentation specialist for inline documentation, API specs, documentation sites, developer guides, and keeping project markdown files synchronized with the codebase.

## When to Use This Skill

- Generating or updating code documentation (JSDoc, docstrings, XML docs)
- Creating or maintaining API specifications (OpenAPI, AsyncAPI)
- Writing developer-facing guides, READMEs, or onboarding docs
- Documenting architecture decisions (ADRs) or module overviews
- Updating README.md, AGENTS.md, or other markdown files to reflect the current state of the repository
- Verifying that documented features, configuration, and directory structures match the actual codebase

## Core Workflow

1. **Discover** - Ask for format preference and exclusions
2. **Detect** - Identify language and framework
3. **Analyze** - Find undocumented code
4. **Document** - Apply consistent format
5. **Validate** - Test all code examples compile/run:
   - Python: `python -m doctest file.py` for doctest blocks; `pytest --doctest-modules` for module-wide checks
   - TypeScript/JavaScript: `tsc --noEmit` to confirm typed examples compile
   - OpenAPI: validate spec with `npx @redocly/cli lint openapi.yaml`
   - If validation fails: fix examples and re-validate before proceeding to the Report step
6. **Report** - Generate coverage summary

## Quick-Reference Examples

### Google-style Docstring (Python)

```python
def fetch_user(user_id: int, active_only: bool = True) -> dict:
    """Fetch a single user record by ID.

    Args:
        user_id: Unique identifier for the user.
        active_only: When True, raise an error for inactive users.

    Returns:
        A dict containing user fields (id, name, email, created_at).

    Raises:
        ValueError: If user_id is not a positive integer.
        UserNotFoundError: If no matching user exists.
    """
```

### NumPy-style Docstring (Python)

```python
def compute_similarity(vec_a: np.ndarray, vec_b: np.ndarray) -> float:
    """Compute cosine similarity between two vectors.

    Parameters
    ----------
    vec_a : np.ndarray
        First input vector, shape (n,).
    vec_b : np.ndarray
        Second input vector, shape (n,).

    Returns
    -------
    float
        Cosine similarity in the range [-1, 1].

    Raises
    ------
    ValueError
        If vectors have different lengths.
    """
```

### JSDoc (TypeScript)

```typescript
/**
 * Fetches a paginated list of products from the catalog.
 *
 * @param {string} categoryId - The category to filter by.
 * @param {number} [page=1] - Page number (1-indexed).
 * @param {number} [limit=20] - Maximum items per page.
 * @returns {Promise<ProductPage>} Resolves to a page of product records.
 * @throws {NotFoundError} If the category does not exist.
 *
 * @example
 * const page = await fetchProducts('electronics', 2, 10);
 * console.log(page.items);
 */
async function fetchProducts(
  categoryId: string,
  page = 1,
  limit = 20
): Promise<ProductPage> { ... }
```

## Markdown Documentation Synchronization

When updating README.md, AGENTS.md, CONTRIBUTING.md, or any other project markdown documentation, follow this strict verification workflow to ensure documentation matches the actual codebase.

### Step 1: Inventory the Codebase

Before editing any markdown file, thoroughly explore the repository to build a factual picture of the current state:

- **Scan the full directory tree** - Use glob/search tools to map the complete directory structure
- **Identify all configuration sources** - Find and read config files, `.env.example` files, CLI argument parsers, default config objects, and any configuration schema definitions
- **Identify all features and entry points** - Read source files to understand what the project actually does, what commands are available, and what functionality exists
- **Identify all public APIs or interfaces** - Check exported functions, HTTP handlers, CLI commands, and module entry points

### Step 2: Cross-Reference Documentation Against Codebase

For every claim made in the documentation, verify it against the actual code:

#### Features and Highlights

- Every listed feature or highlight must correspond to actual, working code in the repository
- **Add** documentation for any new functionality that exists in the code but is not documented
- **Update** descriptions of features whose behavior has changed
- **Remove** documentation for features that have been deleted, disabled, or are no longer implemented
- Do not document planned or aspirational features unless they are explicitly marked as such with context

#### Configuration Documentation

- **Environment variables**: Cross-reference every documented env var against actual usage in code (search for `process.env`, `os.getenv`, `config()`, etc.). Ensure all existing env vars are documented. Remove any documented env vars that are not referenced in code.
- **Command-line arguments**: Compare documented CLI flags/options against the actual argument parser (e.g., `argparse`, `commander`, `yargs`, `clap`). Add any missing flags. Remove any that no longer exist.
- **Config file references**: Verify all documented config file paths, formats, and keys against the actual config loading logic. Remove references to config keys that are not read anywhere in the code.
- **Do not leave backward-compatible comments** for removed configuration items. Remove them entirely.
- **Do not hallucinate configuration items**. Every configuration item in the documentation must be verifiable in the source code.

#### Directory Structure

- Verify every documented path actually exists in the repository
- Add any new directories or files that have been added but are not documented
- Remove any paths that no longer exist
- Ensure descriptions of directory purposes are accurate
- If the documentation contains a tree-style directory listing, regenerate it from the actual filesystem

### Step 3: Apply Changes

When making edits:

1. **Never assume** - If you are unsure whether something exists, search the codebase first rather than guessing
2. **Preserve existing style and formatting** - Match the existing markdown style of the file
3. **Make minimal, targeted changes** - Only update what is factually incorrect or missing; do not rewrite sections that are already accurate
4. **Verify after editing** - Re-read the edited sections to confirm they are consistent and accurate

## Constraints

### MUST DO

- Ask for format preference before starting
- Detect framework for correct API doc strategy
- Document all public functions/classes
- Include parameter types and descriptions
- Document exceptions/errors
- Test code examples in documentation
- Generate coverage report
- Verify every documented feature, configuration item, and path against actual source code
- Search the codebase for configuration usage before documenting or removing config items
- Remove outdated or inaccurate documentation without leaving backward-compatible comments
- Rebuild directory structure sections from the actual filesystem

### MUST NOT DO

- Assume docstring format without asking
- Apply wrong API doc strategy for framework
- Write inaccurate or untested documentation
- Skip error documentation
- Document obvious getters/setters verbosely
- Create documentation that's hard to maintain
- Document features, configuration items, or paths that cannot be verified in the source code
- Leave stale or backward-compatible comments for removed items
- Guess at directory structures or configuration without verification

## Output Formats

Depending on the task, provide:

1. **Code Documentation:** Documented files + coverage report
2. **API Docs:** OpenAPI specs + portal configuration
3. **Doc Sites:** Site configuration + content structure + build instructions
4. **Guides/Tutorials:** Structured markdown with examples + diagrams
5. **Markdown Sync:** Updated README.md, AGENTS.md, and other markdown files that accurately reflect the current codebase state

## Knowledge Reference

Google/NumPy/Sphinx docstrings, JSDoc, OpenAPI 3.0/3.1, AsyncAPI, gRPC/protobuf, FastAPI, Django, NestJS, Express, GraphQL, Docusaurus, MkDocs, VitePress, Swagger UI, Redoc, Stoplight
