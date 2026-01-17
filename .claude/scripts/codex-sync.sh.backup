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

set -euo pipefail

# Configuration
MODEL="${CODEX_MODEL:-gpt-5.2}"
REASONING_EFFORT="${CODEX_REASONING_EFFORT:-}"
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

# Check if codex is installed
if ! command -v codex &> /dev/null; then
    echo "Error: Codex CLI not found. Install with: npm install -g @openai/codex" >&2
    exit 1
fi

# Check if jq is installed (for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "Error: jq not found. Install with: brew install jq" >&2
    exit 1
fi

# Find timeout command (macOS uses gtimeout from coreutils)
TIMEOUT_CMD=""
if command -v gtimeout &> /dev/null; then
    TIMEOUT_CMD="gtimeout"
elif command -v timeout &> /dev/null; then
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
        -c "reasoning_effort=\"$REASONING_EFFORT\"" \
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
