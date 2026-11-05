# AGENTS.md

This repository is a collection of Python project templates. Each template
directory is an **independent project** meant to be copied into the root of a
new repository (see `README.md`):

| Directory | Template |
|---|---|
| `api/` | Async FastAPI REST API |
| `library/` | Publishable PyPI package (hatchling) |

There is no project at the repository root: no `pyproject.toml`, lockfile or
virtual environment is shared between templates. Run every command from inside
the template you are changing (`cd api` or `cd library`), following that
template's `AGENTS.md` and `README.md`. A change that applies to both templates
must be made, and verified, in both.

## CI

The root workflow `.github/workflows/quality-gate.yaml` runs on pull requests
and pushes to `main`. It calls `prefeitura-rio/actions/quality-gate@master`
for both templates in a matrix (`working-directory: api` and `library`):

- `<template> / app:format`, `app:lint`, `app:strlint`, `app:typecheck` in parallel;
- `<template> / app:test` after all of them pass.

The workflows under `api/.github/workflows/` and `library/.github/workflows/`
are part of the templates. GitHub does not run them here; they only run after a
template is copied into its own repository.
