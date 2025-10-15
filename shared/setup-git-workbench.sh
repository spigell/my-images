#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: setup-git-workbench [--name NAME] [--email EMAIL] [--editor EDITOR]

Configure Git defaults for ephemeral workbench environments. Values can be supplied via
flags or provided interactively when omitted.
USAGE
}

name=""
email=""
editor=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      name="$2"
      shift 2
      ;;
    --email)
      email="$2"
      shift 2
      ;;
    --editor)
      editor="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$name" ]]; then
  read -rp "Enter your display name for Git commits: " name
fi

if [[ -z "$email" ]]; then
  read -rp "Enter the email address associated with your Git identity: " email
fi

if [[ -z "$editor" ]]; then
  default_editor="${VISUAL:-${EDITOR:-vim}}"
  read -rp "Preferred editor for git commit messages [$default_editor]: " editor
  editor="${editor:-$default_editor}"
fi

git config --global user.name "$name"
git config --global user.email "$email"
git config --global core.editor "$editor"
git config --global init.defaultBranch main

echo "Configured Git identity for $name <$email>"

echo "Git configuration complete."
echo "Verify your settings with:"
echo "  git config --global --list"
