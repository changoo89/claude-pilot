#!/bin/bash
# codex-sync.sh - Synchronous Codex wrapper for GPT expert delegation
#
# This script replaces the async MCP codex tool with synchronous execution.
# It calls `codex exec` and extracts the final response text.
#
# Usage:
#   codex-sync.sh <mode> <prompt> [working_dir]
#
# Arguments:
#   mode        - "read-only" (Advisory) or "workspace-write" (Implementation)
#   prompt      - The delegation prompt for GPT expert
#   working_dir - Optional working directory (defaults to current dir)
#
# Examples:
#   codex-sync.sh read-only "Analyze tradeoffs of Redis vs in-memory caching"
#   codex-sync.sh workspace-write "Fix the SQL injection in user.ts"
#
# Environment Variables:
#   DEBUG       - Set to 1 to enable diagnostic output

set -euo pipefail

# =============================================================================
# PATH Initialization for Non-Interactive Shells
# =============================================================================
# Non-interactive shells (used by automation tools) don't source ~/.bashrc or
# ~/.zshrc, which means PATH may not include npm global bin directories where
# codex is installed. This section ensures PATH is properly initialized.
# =============================================================================

if [ -n "${ZSH_VERSION:-}" ] && [ -f ~/.zshrc ]; then
    source ~/.zshrc 2>/dev/null || true
elif [ -n "${BASH_VERSION:-}" ] && [ -f ~/.bashrc ]; then
    source ~/.bashrc 2>/dev/null || true
fi

[ -n "${DEBUG:-}" ] && echo "DEBUG: Current PATH: $PATH" >&2

# Configuration
MODEL="${CODEX_MODEL:-gpt-5.2}"
TIMEOUT_SEC="${CODEX_TIMEOUT:-300}"  # 5 minutes default

# Parse arguments
MODE="${1:-read-only}"
PROMPT="${2:-}"
WORKDIR="${3:-.}"

# Validate mode
if [[ "$MODE" != "read-only" && "$MODE" != "workspace-write" ]]; then
    echo "Error: Invalid mode '$MODE'. Use 'read-only' or 'workspace-write'" >&2
    exit 1
fi

# Validate prompt
if [[ -z "$PROMPT" ]]; then
    echo "Error: Prompt is required" >&2
    echo "Usage: codex-sync.sh <mode> <prompt> [working_dir]" >&2
    exit 1
fi

# =============================================================================
# Reliable Command Detection
# =============================================================================
# Multi-layered detection to handle non-interactive shell environments
# where PATH may not be fully populated.
# =============================================================================

# Function to reliably detect commands across shell sessions
# Exit codes: 0 = found, 1 = not found
# If found in common path, adds to PATH automatically
reliable_command_check() {
    local cmd="$1"

    # Layer 1: Try standard detection
    if command -v "$cmd" >/dev/null 2>&1; then
        [ -n "${DEBUG:-}" ] && echo "DEBUG: Found via command -v: $cmd" >&2
        return 0
    fi

    # Layer 2: Check common installation paths
    local common_paths=(
        "/opt/homebrew/bin"           # macOS ARM (Homebrew)
        "/usr/local/bin"               # macOS Intel / Linux
        "/usr/bin"                     # Linux system
        "$HOME/.local/bin"             # User local
        "$HOME/bin"                    # User bin
    )

    for bin_dir in "${common_paths[@]}"; do
        if [ -x "$bin_dir/$cmd" ]; then
            [ -n "${DEBUG:-}" ] && echo "DEBUG: Found via path check: $bin_dir/$cmd" >&2
            # Add to PATH so subsequent calls work
            export PATH="$bin_dir:$PATH"
            [ -n "${DEBUG:-}" ] && echo "DEBUG: Added to PATH: $bin_dir" >&2
            return 0
        fi
    done

    [ -n "${DEBUG:-}" ] && echo "DEBUG: Command not found: $cmd" >&2
    return 1
}

# Check if Codex CLI is installed
if ! reliable_command_check codex; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis" >&2
    echo "To enable GPT delegation, install: npm install -g @openai/codex" >&2
    echo "If already installed, ensure it's in your PATH or ~/.zshrc" >&2
    exit 0  # Graceful fallback - return success to allow Claude to continue
fi

# Check if jq is installed (for JSON parsing)
if ! reliable_command_check jq; then
    echo "Error: jq not found. Install with: brew install jq" >&2
    exit 1
fi

# Find timeout command (macOS uses gtimeout from coreutils)
TIMEOUT_CMD=""
if reliable_command_check gtimeout; then
    TIMEOUT_CMD="gtimeout"
elif reliable_command_check timeout; then
    TIMEOUT_CMD="timeout"
fi

# Create temp file for full output (for debugging)
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

# Execute codex synchronously with JSON output
cd "$WORKDIR"

run_codex() {
    codex exec \
        -m "$MODEL" \
        -s "$MODE" \
        --json \
        "$PROMPT" 2>&1
}

if [[ -n "$TIMEOUT_CMD" ]]; then
    # Use timeout command if available
    $TIMEOUT_CMD "$TIMEOUT_SEC" bash -c "$(declare -f run_codex); run_codex" > "$TEMP_OUTPUT" || {
        EXIT_CODE=$?
        if [[ $EXIT_CODE -eq 124 ]]; then
            echo "Error: Codex execution timed out after ${TIMEOUT_SEC}s" >&2
        else
            echo "Error: Codex execution failed with exit code $EXIT_CODE" >&2
            cat "$TEMP_OUTPUT" >&2
        fi
        exit $EXIT_CODE
    }
else
    # Fallback: run without timeout (macOS without coreutils)
    run_codex > "$TEMP_OUTPUT" || {
        EXIT_CODE=$?
        echo "Error: Codex execution failed with exit code $EXIT_CODE" >&2
        cat "$TEMP_OUTPUT" >&2
        exit $EXIT_CODE
    }
fi

# Extract final agent message from JSON output
# Look for the last item.completed with type "agent_message"
RESPONSE=$(cat "$TEMP_OUTPUT" | \
    grep '"type":"item.completed"' | \
    grep '"agent_message"' | \
    tail -1 | \
    jq -r '.item.text // empty' 2>/dev/null)

# If no agent message found, try to get any meaningful output
if [[ -z "$RESPONSE" ]]; then
    # Try to get reasoning output
    RESPONSE=$(cat "$TEMP_OUTPUT" | \
        grep '"type":"item.completed"' | \
        grep '"reasoning"' | \
        tail -1 | \
        jq -r '.item.text // empty' 2>/dev/null)
fi

# If still empty, show error
if [[ -z "$RESPONSE" ]]; then
    echo "Error: No response extracted from Codex output" >&2
    echo "Raw output:" >&2
    cat "$TEMP_OUTPUT" >&2
    exit 1
fi

# Output the response
echo "$RESPONSE"
