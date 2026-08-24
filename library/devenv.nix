{ pkgs, config, ... }:

{
  name = "library";

  env = {
    UV_PYTHON = config.languages.python.package.outPath;
  };

  languages.python = {
    enable = true;
    package = pkgs.python313;
    lsp.package = pkgs.basedpyright;
    uv = {
      enable = true;
      sync = {
        enable = true;
        allGroups = true;
      };
    };
  };

  packages = [ pkgs.ast-grep ];

  tasks = {
    "app:format" = {
      exec = "uv run ruff format .";
    };

    "app:format:check" = {
      exec = "uv run ruff format --check .";
    };

    "app:lint" = {
      exec = "uv run ruff check --fix . && uv run basedpyright";
    };

    "app:lint:check" = {
      exec = "uv run ruff check . && uv run basedpyright";
    };

    "app:strlint" = {
      exec = "ast-grep scan --config .quality-gate/sgconfig.yaml";
    };

    "app:strlint:check" = {
      exec = "ast-grep scan --config .quality-gate/sgconfig.yaml";
    };

    "app:typecheck" = {
      exec = "echo 'Python: type checking is covered by basedpyright in app:lint'";
    };

    "app:test" = {
      exec = "uv run pytest --cov=src --cov-report=term-missing";
    };
  };

  git-hooks.hooks = {
    ripsecrets.enable = true;

    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };

    app-format = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-format" ''
        echo "[pre-commit] app:format:check — checking formatting..."
        if ! devenv tasks run app:format:check > /dev/null 2>&1; then
          echo "[pre-commit] app:format — formatting issues found, auto-fixing..."
          devenv tasks run app:format
          git add -u
          echo "[pre-commit] app:format — files auto-formatted and re-staged."
          echo "[pre-commit] Review changes with: git diff --cached"
          echo "[pre-commit] Then commit again to proceed."
          exit 1
        fi
        echo "[pre-commit] app:format:check — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-commit" ];
    };

    app-lint = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-lint" ''
        echo "[pre-commit] app:lint:check — running lint checks..."
        if ! devenv tasks run app:lint:check > /dev/null 2>&1; then
          echo "[pre-commit] app:lint — lint issues found, attempting auto-fix..."
          devenv tasks run app:lint
          git add -u
          echo "[pre-commit] app:lint — auto-fix applied and re-staged."
          echo "[pre-commit] Review changes with: git diff --cached"
          echo "[pre-commit] Then commit again to proceed."
          exit 1
        fi
        echo "[pre-commit] app:lint:check — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-commit" ];
    };

    app-strlint = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-strlint" ''
        echo "[pre-commit] app:strlint:check — running structural lint..."
        if ! devenv tasks run app:strlint:check > /dev/null 2>&1; then
          echo "[pre-commit] app:strlint:check — failed. Fix violations above."
          exit 1
        fi
        echo "[pre-commit] app:strlint:check — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-commit" ];
    };

    app-typecheck = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-typecheck" ''
        echo "[pre-push] app:typecheck — running type checks..."
        if ! devenv tasks run app:typecheck; then
          echo "[pre-push] app:typecheck — failed."
          exit 1
        fi
        echo "[pre-push] app:typecheck — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-push" ];
    };

    app-test = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-test" ''
        echo "[pre-push] app:test — running tests..."
        if ! devenv tasks run app:test; then
          echo "[pre-push] app:test — failed."
          exit 1
        fi
        echo "[pre-push] app:test — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-push" ];
    };
  };
}
