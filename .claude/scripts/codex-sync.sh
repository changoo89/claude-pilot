#!/bin/bash
# codex-sync.sh - Thin wrapper for GPT expert delegation
# Full procedures: @.claude/skills/gpt-delegation/SKILL.md
# Usage: codex-sync.sh <mode> <prompt> [working_dir]

# CRITICAL: Claude agents MUST use this wrapper script ONLY.
# NEVER call codex CLI directly with options like:
#   - codex --sandbox read-only --quiet (--quiet doesn't exist)
#   - codex --sandbox read-only (missing exec subcommand)
# Correct format is handled by this script: codex exec -m MODEL -s MODE --json "PROMPT"

# Set PROJECT_DIR (self-contained, no external dependency)
if [[ -z "${PROJECT_DIR:-}" ]]; then
    if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
        PROJECT_DIR="$CLAUDE_PROJECT_DIR"
    else
        PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    fi
fi

set -eo pipefail

# Check for flag-style arguments (common mistake)
if [[ "${1:-}" == --* ]]; then
  echo "Error: This script uses positional arguments, not flags." >&2
  echo "" >&2
  echo "Usage: codex-sync.sh <mode> <prompt> [working_dir]" >&2
  echo "" >&2
  echo "Parameters:" >&2
  echo "  mode    : 'read-only' (advisory) or 'workspace-write' (implementation)" >&2
  echo "  prompt  : The delegation prompt text" >&2
  echo "  working_dir : Optional working directory (default: current)" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  .claude/scripts/codex-sync.sh \"read-only\" \"You are a software architect...\"" >&2
  echo "" >&2
  echo "Received: $*" >&2
  exit 1
fi

MODEL="${CODEX_MODEL:-gpt-5.2}"
TIMEOUT_SEC="${CODEX_TIMEOUT:-300}"
MODE="${1:-read-only}"
PROMPT="${2:-}"
WORKDIR="${3:-.}"

# Validate arguments
if [[ "$MODE" != "read-only" && "$MODE" != "workspace-write" ]]; then
  echo "Error: Invalid mode '$MODE'. Use 'read-only' or 'workspace-write'" >&2
  echo "" >&2
  echo "Usage: codex-sync.sh <mode> <prompt> [working_dir]" >&2
  echo "Example: .claude/scripts/codex-sync.sh \"read-only\" \"Your prompt here\"" >&2
  exit 1
fi
if [[ -z "$PROMPT" ]]; then
  echo "Error: Prompt is required" >&2
  exit 1
fi

# Environment setup for non-interactive shells
: "${HOME:=/tmp}"
if [ -n "${ZSH_VERSION:-}" ] && [ -f ~/.zshrc ]; then
  source ~/.zshrc 2>/dev/null || true
elif [ -n "${BASH_VERSION:-}" ] && [ -f ~/.bashrc ]; then
  source ~/.bashrc 2>/dev/null || true
fi

# Codex CLI detection (multi-layer fallback)
command_found=false
for bin_dir in "/opt/homebrew/bin" "/usr/local/bin" "/usr/bin" "$HOME/.local/bin" "$HOME/bin"; do
  if [ -x "$bin_dir/codex" ]; then
    export PATH="$bin_dir:$PATH"
    command_found=true
    break
  fi
done

if ! $command_found && ! command -v codex >/dev/null 2>&1; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis" >&2
  echo "Install: npm install -g @openai/codex" >&2
  exit 0  # Graceful fallback
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq not found. Install: brew install jq" >&2
  exit 1
fi

# Execute Codex delegation
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT
cd "$WORKDIR"

run_codex() {
  codex exec -m "$MODEL" -s "$MODE" --json "$PROMPT" 2>&1
}

# Execute with timeout
TIMEOUT_CMD=""
if command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_CMD="gtimeout"
elif command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD="timeout"
fi

if [[ -n "$TIMEOUT_CMD" ]]; then
  $TIMEOUT_CMD "$TIMEOUT_SEC" bash -c "$(declare -f run_codex); run_codex" > "$TEMP_OUTPUT" || {
    EXIT_CODE=$?
    if [[ $EXIT_CODE -eq 124 ]]; then
      echo "Error: Codex execution timed out after ${TIMEOUT_SEC}s" >&2
    else
      echo "Error: Codex execution failed (exit code $EXIT_CODE)" >&2
      cat "$TEMP_OUTPUT" >&2
    fi
    exit $EXIT_CODE
  }
else
  run_codex > "$TEMP_OUTPUT" || {
    EXIT_CODE=$?
    echo "Error: Codex execution failed (exit code $EXIT_CODE)" >&2
    cat "$TEMP_OUTPUT" >&2
    exit $EXIT_CODE
  }
fi

# Extract response (agent_message or reasoning)
RESPONSE=$(cat "$TEMP_OUTPUT" | grep '"type":"item.completed"' | grep '"agent_message"' | tail -1 | jq -r '.item.text // empty' 2>/dev/null)

if [[ -z "$RESPONSE" ]]; then
  RESPONSE=$(cat "$TEMP_OUTPUT" | grep '"type":"item.completed"' | grep '"reasoning"' | tail -1 | jq -r '.item.text // empty' 2>/dev/null)
fi

if [[ -z "$RESPONSE" ]]; then
  echo "Error: No response extracted from Codex output" >&2
  cat "$TEMP_OUTPUT" >&2
  exit 1
fi

echo "$RESPONSE"
