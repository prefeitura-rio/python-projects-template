# AGENTS.md

Publishable PyPI package (Python 3.13, uv, hatchling). See `README.md` for the
stack and the project structure.
Code conventions (layout, naming, docstrings, tests) are in `STYLEGUIDE.md`.

Run every command from this directory, the project root (`library/` inside
`python-projects-template`).

## Setup

```bash
uv sync --frozen
```

`devenv shell` provides the same environment, plus `ast-grep` and the git
hooks.

## Test

```bash
uv run --frozen pytest
uv run --frozen pytest --cov=src --cov-report=term-missing   # as CI runs it (app:test)
```

## Format, lint and type check

```bash
uv run --frozen ruff format --check .                  # app:format
uv run --frozen ruff check .                           # app:lint
uv run --frozen basedpyright                           # app:lint (type check)
ast-grep scan --config .quality-gate/sgconfig.yaml     # app:strlint
```

To apply fixes: `uv run --frozen ruff format .` and
`uv run --frozen ruff check --fix .`.

`ast-grep` is installed by devenv, not by uv. Outside devenv, run
`uvx --from ast-grep-cli ast-grep scan --config .quality-gate/sgconfig.yaml`.

`app:typecheck` is a no-op for Python: type checking is done by basedpyright.

## Build

```bash
uv build
```

Writes the sdist and the wheel to `dist/`. Publishing (`uv publish`) is a
release step; do not run it from a task.

## Before you push

All the checks above must pass. They are the jobs of the quality gate
(`app:format`, `app:lint`, `app:strlint`, `app:typecheck`, then `app:test`),
also defined as devenv tasks in `devenv.nix` (`devenv tasks run app:<task>`).
