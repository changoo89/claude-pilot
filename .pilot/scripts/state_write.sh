#!/bin/bash
# state_write.sh: Write continuation state to JSON file
# Usage: state_write.sh --plan-file PATH --todos JSON --iteration N

set -euo pipefail

# Default state directory
STATE_DIR="${STATE_DIR:-.pilot/state}"

# Parse arguments
PLAN_FILE=""
TODOS_JSON=""
ITERATION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --plan-file)
            PLAN_FILE="$2"
            shift 2
            ;;
        --todos)
            TODOS_JSON="$2"
            shift 2
            ;;
        --iteration)
            ITERATION="$2"
            shift 2
            ;;
        --state-dir)
            STATE_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$PLAN_FILE" ] || [ -z "$TODOS_JSON" ] || [ -z "$ITERATION" ]; then
    echo "Usage: $0 --plan-file PATH --todos JSON --iteration N" >&2
    exit 1
fi

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Continuation file path
CONTINUATION_FILE="$STATE_DIR/continuation.json"

# Backup existing state before write
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$CONTINUATION_FILE" ]; then
    bash "$SCRIPT_DIR/state_backup.sh" --state-dir "$STATE_DIR"
fi

# Generate session ID (UUID)
SESSION_ID="$(uuidgen 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())' || echo 'unknown')"

# Get current branch
BRANCH="$(git branch --show-current 2>/dev/null || echo 'unknown')"

# Get current timestamp (ISO 8601)
LAST_CHECKPOINT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Get max iterations from env or default
MAX_ITERATIONS="${MAX_ITERATIONS:-7}"

# Get continuation level from env or default
CONTINUATION_LEVEL="${CONTINUATION_LEVEL:-normal}"

# Build JSON using jq for safe JSON generation (prevents injection)
# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for safe JSON generation" >&2
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)" >&2
    exit 1
fi

# Validate TODOS_JSON is valid JSON before using
if ! jq -e . <<< "$TODOS_JSON" &> /dev/null; then
    echo "Error: Invalid todos JSON provided" >&2
    exit 1
fi

# Safe JSON generation using jq (prevents JSON injection attacks)
jq -n \
    --arg session_id "$SESSION_ID" \
    --arg branch "$BRANCH" \
    --arg plan_file "$PLAN_FILE" \
    --argjson todos "$TODOS_JSON" \
    --argjson iteration_count "$ITERATION" \
    --argjson max_iterations "$MAX_ITERATIONS" \
    --arg last_checkpoint "$LAST_CHECKPOINT" \
    --arg continuation_level "$CONTINUATION_LEVEL" \
    '{
        version: "1.0",
        session_id: $session_id,
        branch: $branch,
        plan_file: $plan_file,
        todos: $todos,
        iteration_count: $iteration_count,
        max_iterations: $max_iterations,
        last_checkpoint: $last_checkpoint,
        continuation_level: $continuation_level
    }' > "$CONTINUATION_FILE"

# Validate generated JSON is valid
if ! jq empty "$CONTINUATION_FILE" 2>/dev/null; then
    echo "Error: Failed to generate valid JSON" >&2
    exit 1
fi

echo "Continuation state written to: $CONTINUATION_FILE"
exit 0
