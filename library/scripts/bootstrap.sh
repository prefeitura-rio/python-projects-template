#!/usr/bin/env bash

set -eu -o pipefail

step() {
  echo ""
  echo "===> $*"
}

ok() {
  echo "  [ok] $*"
}

note() {
  echo "  [note] $*"
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_interactive() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    die "project initialization requires an interactive terminal"
  fi
}

confirm_initialization() {
  local answer
  read -r -p "  Apply these changes? [Y/n] " answer
  if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
    die "project initialization cancelled"
  fi
}

initialize_project() {
  local project_name
  local snake_name

  if ! grep -q 'name = "my-library"' pyproject.toml; then
    return
  fi

  require_interactive

  [[ -f pyproject.toml && -f devenv.nix && -d src/my_library ]] || die "template library files are missing"

  read -r -p "Project name: " project_name
  [[ "$project_name" =~ ^[A-Za-z0-9]+([._-][A-Za-z0-9]+)*$ ]] || die "project name must use letters, numbers, dots, underscores, or hyphens"
  [[ "$project_name" != "my-library" ]] || die "project name cannot be the template placeholder"

  snake_name="${project_name,,}"
  snake_name="${snake_name//-/_}"
  snake_name="${snake_name//./_}"
  [[ "$snake_name" =~ ^[a-z][a-z0-9_]*$ ]] || die "project name must derive a valid Python package name"
  case "$snake_name" in
    and|as|assert|async|await|break|case|class|continue|def|del|elif|else|except|False|finally|for|from|global|if|import|in|is|lambda|match|None|nonlocal|not|or|pass|raise|return|True|try|type|while|with|yield)
      die "project name derives a Python keyword and cannot be used as a package name"
      ;;
  esac
  [[ ! -e "src/$snake_name" ]] || die "target Python package directory already exists"

  echo ""
  echo "Initializing project from template..."
  echo ""
  echo "  Project name  : $project_name"
  echo "  Python package: $snake_name"
  echo ""
  echo "  Changes to apply:"
  echo "    rename  src/my_library/     -> src/$snake_name/"
  echo "    update  pyproject.toml      (name + package path)"
  echo "    update  devenv.nix           (name)"

  confirm_initialization

  mv src/my_library "src/$snake_name"
  sed -i "s|name = \"my-library\"|name = \"$project_name\"|" pyproject.toml
  sed -i "s|src/my_library|src/$snake_name|" pyproject.toml
  sed -i "s|name = \"library\"|name = \"$project_name\"|" devenv.nix
  ok "Project initialized"
}

initialize_project

step "Checking for Nix..."

if command -v nix &>/dev/null; then
  ok "Nix is already installed: $(nix --version)"
else
  step "Installing Nix + devenv via the official devenv installer..."
  note "This will install Nix system-wide and may ask for your password."
  note "Source: https://devenv.sh/getting-started/"
  curl -L https://devenv.sh/install.sh | bash

  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi

  ok "Nix installed: $(nix --version)"
fi

step "Checking for devenv..."

if command -v devenv &>/dev/null; then
  ok "devenv is already installed: $(devenv version)"
else
  step "Installing devenv via nix profile..."
  mkdir -p "$HOME/.config/nix"
  if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    ok "Enabled nix-command and flakes in ~/.config/nix/nix.conf"
  fi

  nix profile install nixpkgs#devenv
  ok "devenv installed: $(devenv version)"
fi

step "Setting up devenv shell hook for auto-activation..."

SHELL_NAME="$(basename "${SHELL:-bash}")"

case "$SHELL_NAME" in
  bash)
    HOOK_SNIPPET='eval "$(devenv hook bash)"'
    HOOK_FILE="$HOME/.bashrc"
    ;;
  zsh)
    HOOK_SNIPPET='eval "$(devenv hook zsh)"'
    HOOK_FILE="$HOME/.zshrc"
    ;;
  fish | nu)
    ok "devenv hook is loaded automatically for $SHELL_NAME — nothing to do."
    HOOK_SNIPPET=""
    HOOK_FILE=""
    ;;
  *)
    HOOK_SNIPPET=""
    HOOK_FILE=""
    ;;
esac

if [ -n "$HOOK_FILE" ]; then
  if grep -q 'devenv hook' "$HOOK_FILE" 2>/dev/null; then
    ok "devenv hook already present in $HOOK_FILE"
  else
    echo "$HOOK_SNIPPET" >> "$HOOK_FILE"
    ok "Added devenv hook to $HOOK_FILE"
  fi
elif [ -z "$HOOK_SNIPPET" ] && [ "$SHELL_NAME" != "fish" ] && [ "$SHELL_NAME" != "nu" ]; then
  note "Unknown shell '$SHELL_NAME'."
  note "Add the devenv hook manually: https://devenv.sh/auto-activation/"
fi

step "Trusting devenv project..."
devenv allow
ok "devenv project trusted"

echo ""
echo "============================================================"
echo " Bootstrap complete!"
echo "============================================================"
echo ""
echo " Open a new terminal. The environment activates automatically"
echo " when you navigate to this directory."
echo " Python 3.13 and uv will be available, and uv sync"
echo " will run automatically to set up the virtual environment."
echo ""
