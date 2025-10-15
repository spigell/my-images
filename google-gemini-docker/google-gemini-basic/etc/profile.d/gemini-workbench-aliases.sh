# shellcheck shell=sh
# Configure convenient aliases for Gemini CLI inside the workbench image.
# Reference: https://raw.githubusercontent.com/google-gemini/gemini-cli/refs/heads/main/docs/get-started/configuration.md

case "$-" in
  *i*) ;;
  *) return ;;
esac

# Always-approve helper for fast prototyping sessions.
alias gemin='gemini --approval-mode auto_edit -d'

# Approve edit operations automatically while still prompting for other tools.
alias gemin_edit='gemini --approval-mode auto_edit -d'

# Emit machine-readable output for scripting scenarios.
alias gemin_json='gemini --output-format json -d'

# Quickly enable the sandbox with permissive defaults.
alias gemin_sandbox='gemini --sandbox -d'
