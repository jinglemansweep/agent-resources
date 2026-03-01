---
name: jp-persona-python
description: Python backend conventions and quality gates
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

<!-- tags: python, backend, conventions, quality -->
<!-- category: domain-skills -->

# jp-persona-python

Python backend conventions, quality gates, and domain knowledge. Loaded by the jp-worker-dev agent when handling Python tasks. This is not a user-invocable skill.

## Mandatory Requirements

1. **Virtualenv**: NEVER run Python operations outside a virtualenv. For new projects, create `.venv` at the project root and activate it before any other work. For existing projects, search for `.venv` or `venv` and activate it before any operations.
2. **Quality gates**: ALWAYS run quality gates (`pre-commit` if configured, `pytest` if tests exist) after every unit of work. Never skip them, even for small changes.

## New Project Setup

- Use `uv` for package management and `ruff` for linting/formatting
- Create `pyproject.toml` as the single project configuration file
- Use `.python-version` file to pin the Python version
- Create a `pre-commit` configuration covering linting, formatting, typing
- Create and activate a virtualenv at `<project-root>/.venv`, install all dependencies and local modules before doing anything else

## Existing Project Conventions

- Search for and activate the virtualenv (`.venv` or `venv`) before performing any operations
- Respect existing project conventions, tooling, and structure
- Run existing quality gates (`pre-commit`, `pytest`) if configured, after each unit of work

## Recommended Packages

Prefer these when applicable, but respect existing project choices.

- **Pydantic** -- data models and configuration
- **Click** -- CLI interfaces
- **FastAPI** -- web APIs
- **SQLAlchemy** -- database ORM
- **Alembic** -- database migrations
- **PAHO MQTT** -- MQTT messaging

## Core Principles

- **Readability first** -- prefer clear, obvious code over clever one-liners; optimise for the next reader
- **Explicit over implicit** -- avoid hidden side effects, magic methods that surprise, and implicit state changes
- **EAFP** -- use `try`/`except` rather than pre-condition checks; catch specific exceptions, not `Exception`

## Type Hints

- **Built-in generics** -- use `list[str]`, `dict[str, Any]`, `tuple[int, ...]` (Python 3.10+); avoid `typing.List` etc.
- **Protocol over ABC** -- use `typing.Protocol` for structural (duck) typing instead of abstract base classes where possible
- **TypeVar and aliases** -- use `TypeVar` for generic functions; define `TypeAlias` for complex or repeated type expressions

## Error Handling

- **Specific exceptions** -- always catch the narrowest exception type; never use bare `except:` or broad `except Exception`
- **Exception chaining** -- use `raise NewError(...) from e` to preserve the original traceback
- **Custom hierarchies** -- define a base `AppError` with specific subclasses (e.g. `ValidationError`, `NotFoundError`)

## Context Managers

- **`with` statements** -- always use `with` for resource management: files, connections, locks, temporary state
- **`@contextmanager`** -- use `contextlib.contextmanager` for simple acquire/release patterns
- **Class-based pattern** -- implement `__enter__`/`__exit__` when the manager needs complex state or reuse

## Comprehensions and Generators

- **Generator expressions** -- prefer `(x for x in items)` over `[x for x in items]` when the full list is not needed
- **Complexity threshold** -- if a comprehension has multiple conditions or nested loops, extract to a named function or loop
- **`yield` for lazy iteration** -- use generator functions for large or unbounded data to avoid loading everything into memory

## Decorators

- **`functools.wraps`** -- always apply `@wraps(fn)` to wrapper functions to preserve name, docstring, and signature
- **Parameterised decorators** -- use a decorator factory (outer function returning the decorator) when arguments are needed
- **Class-based decorators** -- use a class with `__call__` when the decorator needs to track state across invocations

## Concurrency

- **I/O-bound** -- use `concurrent.futures.ThreadPoolExecutor` for parallel I/O (network, disk)
- **CPU-bound** -- use `concurrent.futures.ProcessPoolExecutor` for parallel computation
- **Async I/O** -- use `asyncio` with `async`/`await` and `asyncio.gather` for high-concurrency async workloads

## Performance

- **`__slots__`** -- define `__slots__` on data-heavy classes to reduce per-instance memory overhead
- **String joining** -- use `"".join(parts)` instead of repeated `+=` concatenation in loops
- **Return generators** -- return generators or iterators instead of materialised lists for large result sets

## Anti-Patterns

Avoid these; use the correction instead.

- **Mutable default arguments** -- never use `def f(x=[]):`; default to `None` and create inside the function
- **`type()` for type checking** -- use `isinstance(obj, cls)` instead of `type(obj) is cls`
- **`== None` / `!= None`** -- use `is None` / `is not None`
- **Wildcard imports** -- never use `from module import *`; import names explicitly
- **Bare `except:`** -- always catch a specific exception type

## Patterns

- `pyproject.toml` as the single project configuration file
- Create a top-level module/package for the project
- All data models use Pydantic and live in the same module/package
- All configuration via Pydantic with precedence: defaults -> env vars -> CLI args
- Separate `cli` module using Click if the project needs a CLI
- Create mock objects for offline testing
- Create applicable unit tests for new features with minimum coverage targets
- **`NamedTuple`** -- use `typing.NamedTuple` as an immutable, lightweight alternative to dataclasses when mutability is not needed
- **`__post_init__`** -- use dataclass `__post_init__` for field validation and derived-field computation at construction time

## Domain Expertise

- Python 3.10+ idioms and best practices (type hints, dataclasses, pathlib, f-strings)
- Web frameworks: FastAPI, Django, Flask -- follow whichever the project uses
- Testing: pytest conventions (fixtures, parametrize, conftest.py)
- Packaging: pyproject.toml with uv (preferred), pip, poetry -- use what the project uses
- Async patterns with asyncio where appropriate
- Follow PEP 8 and existing project style; use ruff for linting and formatting
- Use existing project structure for new modules (match import style, directory layout)

## Quality Gates

Run these after every unit of work, no exceptions.

- Run `pre-commit run --all-files` if a `.pre-commit-config.yaml` exists
- Run `pytest` (or the project's test command) if tests exist
- If either gate fails, fix the issue before moving on
