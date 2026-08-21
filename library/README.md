# Python Library Template

A minimal, production-ready Python library starter for packages published to
PyPI. Copy the contents of this directory into a new repository root and start
building.

## Stack

| Concern | Choice |
|---|---|
| Language | Python 3.13 |
| Package manager | uv |
| Build backend | hatchling (PEP 517-compliant) |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` |
| Formatting | ruff format |
| Linting | ruff check + basedpyright |
| Tests | pytest + pytest-cov |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@master` |

## Project structure

```
src/my_library/
├── __init__.py   # Re-exports the public API surface
└── example.py    # Placeholder: replace with actual code
tests/
└── test_example.py
```

The source code lives under `src/my_library/` (the "src layout"). This
prevents Python from accidentally importing from the project root rather than
the installed package, which avoids subtle import bugs during testing.

## How to use

Copy this directory into a new, empty repository and run the bootstrap script:

```bash
cp -r python-projects-template/library/. my-library/
cd my-library
bash scripts/bootstrap.sh
```

The script prompts for the project name, derives the Python package name, renames
`src/my_library/`, updates the Hatch package path and project metadata, installs
the development environment, and trusts the project automatically. Open a
**new terminal** after the script finishes.

Verify everything works:

```bash
uv run pytest
uv run ruff check .
uv run ruff format --check .
```

## Publishing to PyPI

Build a distribution:
```bash
uv build
```

This produces `dist/my_library-0.1.0.tar.gz` and
`dist/my_library-0.1.0-py3-none-any.whl`.

Publish:
```bash
uv publish
```

You will be prompted for your PyPI token. Set `UV_PUBLISH_TOKEN` to skip the
prompt in CI.

## Adding dependencies

Runtime dependency (shipped with the library):
```bash
uv add requests
```

Development-only dependency (not published to PyPI):
```bash
uv add --group dev pytest-mock
```

## CI pipeline

Five jobs run on every push and pull request to `main`:

```
format ──┐
lint   ──┤
strlint──┼──> test
typecheck┘
```

`format`, `lint`, `strlint`, and `typecheck` run in parallel. `test` runs
only after all four pass. The `typecheck` job is a no-op for Python — type
checking is handled by basedpyright inside the `lint` job.
