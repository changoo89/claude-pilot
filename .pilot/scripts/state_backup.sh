#!/bin/bash
# state_backup.sh: Backup continuation state before writes
# Usage: state_backup.sh [--state-dir PATH]

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
BACKUP_FILE="$STATE_DIR/continuation.json.backup"

# Create backup if file exists
if [ -f "$CONTINUATION_FILE" ]; then
    if ! cp "$CONTINUATION_FILE" "$BACKUP_FILE"; then
        echo "Error: Failed to create backup: $BACKUP_FILE" >&2
        exit 1
    fi
    echo "Backup created: $BACKUP_FILE"
else
    echo "No existing state file to backup"
fi

exit 0
