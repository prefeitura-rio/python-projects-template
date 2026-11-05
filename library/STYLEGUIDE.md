# STYLEGUIDE.md

Code conventions of the PyPI library template. They describe what the template
code already does; follow them when adding code so new modules look like the
existing ones. Tooling that enforces part of them is listed at the end. For
commands, see `AGENTS.md`.

## Layout

The code uses the src layout: the package is `src/my_library/` (renamed by
`scripts/bootstrap.sh`), tests live in `tests/`, outside the package. The
wheel ships only `src/my_library` (`[tool.hatch.build.targets.wheel]`).

```
src/my_library/
├── __init__.py   # Public API: re-exports and __all__
└── example.py    # Implementation modules
tests/
└── test_example.py
```

## Public API

- Implementation lives in modules such as `example.py`.
- `__init__.py` re-exports what users may import and lists it in `__all__`
  (`from my_library.example import add`, `__all__ = ["add"]`). Anything not in
  `__all__` is internal.
- Users and tests import from the package root (`from my_library import add`).

## Dependencies

Runtime dependencies go in `[project].dependencies` (`uv add <pkg>`); tools used
only for development go in the `dev` group (`uv add --group dev <pkg>`). The
template has no runtime dependency: add one only when the library needs it.

## Imports

- Absolute imports from the package root: `from my_library.example import add`.
  `scripts/bootstrap.sh` renames the package by rewriting `my_library` in
  `src/` and `tests/`.
- Import order and grouping are ruff's isort rules (`I`): standard library,
  third party, then the package.

## Naming and types

- Modules and functions `snake_case`, classes `PascalCase`, constants
  `UPPER_CASE`; module-private names start with `_` (pep8-naming, ruff `N`).
- Every function has parameter and return annotations, tests included
  (`-> None`). Use modern syntax (`X | None`, `list[str]`) and
  `collections.abc` for abstract types (ruff `UP`).
- The code has no `# type: ignore`: fix the type instead of silencing basedpyright.

## Docstrings

- Every module starts with a one-line docstring (`"""Example library module."""`).
- Public functions and classes use Google-style docstrings: a summary line,
  then `Args:` and `Returns:` (and `Raises:` when they raise), as in
  `example.add`.

## Errors and logging

- No bare `except:`; catch a specific exception type.
- No `print()` in `src/`; use `logging.getLogger(__name__)` and leave handler
  configuration to the application that uses the library.
- No `eval()` or `exec()`.

## Tests

- `tests/test_<module>.py`, flat, one file per module, with a module docstring
  (`"""Tests for my_library.example."""`).
- Test functions are named `test_<behavior>` (`test_add_negative_numbers`),
  have no docstring and are annotated `-> None`.
- Tests import the public API from the package root, as users do.

## Enforced by tooling

| Rule | Tool (config) |
|---|---|
| Formatting: line length 100, double quotes | ruff format (`pyproject.toml`) |
| Lint rules `E`, `F`, `I`, `N`, `W`, `UP` | ruff check (`pyproject.toml`) |
| Types, mode `standard`, Python 3.13 | basedpyright (`pyproject.toml`) |
| `no-bare-except`, `no-print` (outside tests), `no-eval` | ast-grep (`.quality-gate/rules/`) |
