#!/bin/bash
# state_read.sh: Read continuation state from JSON file
# Usage: state_read.sh [--state-dir PATH]

set -euo pipefail

# Default state directory
STATE_DIR="${STATE_DIR:-.pilot/state}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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

# Continuation file path
CONTINUATION_FILE="$STATE_DIR/continuation.json"

# Check if file exists
if [ ! -f "$CONTINUATION_FILE" ]; then
    echo "Error: Continuation state file not found: $CONTINUATION_FILE" >&2
    exit 1
fi

# Validate JSON before output (prevents reading corrupted files)
if ! command -v jq &> /dev/null; then
    echo "Warning: jq not found - skipping JSON validation" >&2
else
    if ! jq empty "$CONTINUATION_FILE" 2>/dev/null; then
        echo "Error: Continuation state file contains invalid JSON: $CONTINUATION_FILE" >&2
        echo "Run: jq '.' $CONTINUATION_FILE to see validation errors" >&2
        exit 1
    fi
fi

# Output validated JSON content
cat "$CONTINUATION_FILE"
exit 0
