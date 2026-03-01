# Product Requirements Document

> Source: `.plans/2026/03/01/02-improve-python-skill/prompt.md`

## Project Overview

Enhance the `jms-role-python` agent by incorporating idiomatic Python patterns and best practices from the external `python-patterns` skill ([source](https://github.com/affaan-m/everything-claude-code/blob/main/skills/python-patterns/SKILL.md)). The current agent covers tooling, workflow, and project conventions well but lacks detailed guidance on Python idioms, patterns, and anti-patterns. This update merges that guidance into the agent definition so the Python specialist produces higher-quality, more idiomatic code.

## Goals

- The Python agent produces code that follows established Python idioms (EAFP, explicit over implicit, readability-first) without needing a separate skill reference
- The agent has concrete guidance on type hints, error handling, context managers, generators, decorators, and concurrency patterns
- The agent avoids common Python anti-patterns (mutable defaults, bare excepts, type() comparisons, None equality checks)
- The agent's existing structure, conventions, and constraints remain intact — the update is additive, not a rewrite

## Functional Requirements

### REQ-001: Add Core Principles Section

**Description:** Add a "Core Principles" section to the agent that establishes the foundational Python philosophy the agent must follow: readability counts, explicit over implicit, and EAFP (Easier to Ask Forgiveness than Permission).

**Acceptance Criteria:**

- [ ] The agent file contains a "Core Principles" section with guidance on readability, explicitness, and EAFP
- [ ] The principles are stated as actionable directives (not just philosophy) that guide code generation decisions

### REQ-002: Expand Type Hints Guidance

**Description:** Add detailed type hints guidance covering modern Python 3.10+ syntax (built-in generics), TypeVar, Protocol-based duck typing, and type aliases. The current agent mentions type hints in Domain Expertise but lacks concrete patterns.

**Acceptance Criteria:**

- [ ] The agent includes guidance on using built-in generic types (`list[str]`, `dict[str, Any]`) over `typing` module equivalents for Python 3.10+
- [ ] Protocol-based structural typing is documented as a preferred pattern for duck typing
- [ ] Type alias and TypeVar usage patterns are included

### REQ-003: Add Error Handling Patterns

**Description:** Add an error handling patterns section covering specific exception catching, exception chaining with `from`, and custom exception hierarchies.

**Acceptance Criteria:**

- [ ] The agent instructs to catch specific exceptions rather than bare `except`
- [ ] Exception chaining (`raise ... from e`) is documented as a required pattern
- [ ] Custom exception hierarchy pattern (base app error with specific subclasses) is included

### REQ-004: Add Context Manager Patterns

**Description:** Add guidance on context managers for resource management, including the `contextlib.contextmanager` decorator and class-based context managers with `__enter__`/`__exit__`.

**Acceptance Criteria:**

- [ ] The agent instructs to use `with` statements for resource management
- [ ] Both decorator-based (`@contextmanager`) and class-based context manager patterns are documented

### REQ-005: Add Comprehension and Generator Patterns

**Description:** Add guidance on when to use list comprehensions vs generator expressions vs generator functions, including guidance on when comprehensions become too complex and should be expanded.

**Acceptance Criteria:**

- [ ] The agent includes guidance on preferring generator expressions for large datasets (lazy evaluation)
- [ ] A complexity threshold is stated: comprehensions with multiple conditions should be expanded to loops or functions

### REQ-006: Add Decorator Patterns

**Description:** Add decorator patterns covering function decorators (with `functools.wraps`), parameterized decorators, and class-based decorators.

**Acceptance Criteria:**

- [ ] The agent requires `functools.wraps` on all decorator wrappers
- [ ] Parameterized decorator pattern (decorator factory) is documented
- [ ] Class-based decorator pattern with `__call__` is documented

### REQ-007: Add Concurrency Patterns

**Description:** Add concurrency patterns covering ThreadPoolExecutor for I/O-bound work, ProcessPoolExecutor for CPU-bound work, and async/await with asyncio.

**Acceptance Criteria:**

- [ ] The agent distinguishes between I/O-bound (threading) and CPU-bound (multiprocessing) concurrency
- [ ] `concurrent.futures` is documented as the preferred high-level interface for both
- [ ] Async/await patterns with `asyncio.gather` are included

### REQ-008: Add Memory and Performance Patterns

**Description:** Add performance-oriented patterns: `__slots__` for memory efficiency, generators for large data, and string joining instead of concatenation in loops.

**Acceptance Criteria:**

- [ ] `__slots__` is documented as a pattern for memory-critical classes
- [ ] String concatenation in loops is flagged as an anti-pattern with `"".join()` as the alternative
- [ ] Generator functions are recommended over list returns for large datasets

### REQ-009: Add Anti-Patterns Section

**Description:** Add an explicit anti-patterns section listing common Python mistakes the agent must avoid: mutable default arguments, `type()` instead of `isinstance()`, `== None` instead of `is None`, `from module import *`, and bare `except`.

**Acceptance Criteria:**

- [ ] Each anti-pattern is listed with the correct alternative
- [ ] The section contains at minimum: mutable defaults, type checking, None comparison, wildcard imports, bare except

### REQ-010: Preserve Existing Agent Structure and Content

**Description:** All existing sections of `jms-role-python.md` must be preserved. The update is additive — existing Mandatory Requirements, New Projects, Existing Projects, Recommended Packages, Patterns, Domain Expertise, Workflow, Quality Gates, and Constraints sections remain unchanged in meaning and intent.

**Acceptance Criteria:**

- [ ] All existing section headings are present in the updated agent
- [ ] Existing mandatory requirements (virtualenv, quality gates) are unchanged
- [ ] Existing constraints (no commits, tasks.md as source of truth) are unchanged
- [ ] The agent frontmatter (name, description) is preserved

## Non-Functional Requirements

### REQ-011: Agent File Conciseness

**Category:** Maintainability

**Description:** The agent file must remain concise and scannable. Patterns should be described with brief directives and minimal inline examples, not lengthy code blocks. The agent is an instruction set, not a tutorial.

**Acceptance Criteria:**

- [ ] New sections use bullet points and short directives rather than multi-line code blocks
- [ ] The total agent file length does not exceed approximately 200 lines
- [ ] Code examples, if included, are no more than 3-5 lines each and only where a text description would be ambiguous

### REQ-012: Consistency with Existing Agent Style

**Category:** Maintainability

**Description:** New sections must match the tone, formatting, and structure of existing sections in `jms-role-python.md` — Markdown with `##` section headers, bullet lists, and bold emphasis for key terms.

**Acceptance Criteria:**

- [ ] New sections use `##` headers consistent with existing sections
- [ ] Bullet list formatting matches existing patterns (dash prefix, bold key terms)
- [ ] No emojis, no admonition blocks — plain Markdown only

## Technical Constraints and Assumptions

### Constraints

- The output is a single Markdown file: `plugins/jinglemansweep/agents/jms-role-python.md`
- The file must retain its YAML frontmatter (`name`, `description`)
- No external dependencies or auxiliary files — the agent is fully self-contained in one file
- Must follow the project convention: agents are single Markdown files in the `agents/` directory

### Assumptions

- The external skill content from `affaan-m/everything-claude-code` is used as inspiration and reference, not copied verbatim — patterns are adapted to fit the agent's directive style
- Python 3.10+ is the baseline, matching the existing agent's "Python 3.10+ idioms" reference
- The agent is consumed by Claude Code as an agent definition — it must remain an instruction set, not documentation

## Scope

### In Scope

- Adding new pattern/idiom sections to `jms-role-python.md` derived from the external skill
- Reorganizing or lightly editing existing sections if needed for coherent integration
- Updating the Domain Expertise section if new topics warrant it

### Out of Scope

- Creating a separate SKILL.md file — the patterns are merged directly into the agent
- Modifying other agent files (nodejs, frontend, devops, etc.)
- Adding code examples longer than a few lines — this is an agent directive, not a reference guide
- Changing the agent's workflow, quality gates, or constraints
- Updating `README.md` or other project documentation (separate task if needed)

## Suggested Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Format | Markdown with YAML frontmatter | Specified by project conventions for agent files |
| Target | `plugins/jinglemansweep/agents/jms-role-python.md` | Existing agent file to be enhanced |
