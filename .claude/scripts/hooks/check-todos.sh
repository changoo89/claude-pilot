#!/usr/bin/env bash
# Ralph Continuation Enforcement Hook
# Runs on session stop to ensure todos are properly completed
# Includes debounce logic to prevent duplicate executions

set -e

# Cleanup handler for temporary files
cleanup_todos_temp_files() {
    # Clean up any temporary files created during execution
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.tmp" ]; then
        rm -f "$CACHE_FILE.tmp" 2>/dev/null || true
    fi
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.lock" ]; then
        rm -f "$CACHE_FILE.lock" 2>/dev/null || true
    fi
}

# Register cleanup trap
trap cleanup_todos_temp_files EXIT INT TERM

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cache file for debounce logic
CACHE_FILE="${CACHE_FILE:-.claude/cache/quality-check.json}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-10}"

# Source cache utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/cache.sh" ]; then
    source "$SCRIPT_DIR/cache.sh"
fi

echo -e "${BLUE}📋 Checking todo completion status...${NC}"

# Look for in-progress plans
IN_PROGRESS_DIR=".pilot/plan/in_progress"

if [ ! -d "$IN_PROGRESS_DIR" ]; then
    # No in-progress directory, nothing to check
    exit 0
fi

# Find active plan for current branch
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

if [ ! -f "$ACTIVE_PTR" ]; then
    # No active plan for this branch
    exit 0
fi

RUN_DIR="$(cat "$ACTIVE_PTR")"
PLAN_FILE="$RUN_DIR/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    # Plan file doesn't exist
    exit 0
fi

# Debounce logic: Check if we've run recently
CURRENT_TIME=$(date +%s)
LAST_RUN=$(jq -r '.last_run["check_todos"] // 0' "$CACHE_FILE" 2>/dev/null || echo "0")

if [ -n "$LAST_RUN" ] && [ "$LAST_RUN" != "0" ] && [ "$LAST_RUN" != "null" ]; then
    TIME_SINCE_RUN=$((CURRENT_TIME - LAST_RUN))

    if [ "$TIME_SINCE_RUN" -lt "$DEBOUNCE_SECONDS" ]; then
        # Within debounce window - skip execution
        echo -e "${YELLOW}⏸ Debounced (last run ${TIME_SINCE_RUN}s ago, threshold: ${DEBOUNCE_SECONDS}s)${NC}"
        exit 0
    fi
fi

# Check for incomplete todos in the plan
INCOMPLETE=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null || echo "0")

# Also check continuation state file (Sisyphus system)
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"
STATE_INCOMPLETE=0

if [ -f "$STATE_FILE" ]; then
    STATE_INCOMPLETE=$(jq '[.todos[] | select(.status != "complete")] | length' "$STATE_FILE" 2>/dev/null)
    # Ensure STATE_INCOMPLETE is a number, default to 0
    STATE_INCOMPLETE=${STATE_INCOMPLETE:-0}
fi

if [ "$INCOMPLETE" -gt "0" ] 2>/dev/null || [ "$STATE_INCOMPLETE" -gt "0" ] 2>/dev/null; then
    echo -e "${YELLOW}⚠ Ralph Continuation Warning:${NC}"

    if [ "$INCOMPLETE" -gt "0" ]; then
        echo -e "  You have $INCOMPLETE incomplete todo(s) in your plan."
        echo -e "  ${YELLOW}Plan location:${NC} $PLAN_FILE"
    fi

    if [ "$STATE_INCOMPLETE" -gt "0" ]; then
        echo -e "  You have $STATE_INCOMPLETE incomplete todo(s) in continuation state."
        echo -e "  ${YELLOW}State file:${NC} $STATE_FILE"
        echo -e "  ${YELLOW}Next action:${NC} Run /00_continue to resume work"
    fi

    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  1. Complete the todos and run /03_close"
    echo -e "  2. Create sub-tasks for blocked items"
    echo -e "  3. Update plan to reflect actual completion status"

    if [ "$STATE_INCOMPLETE" -gt "0" ]; then
        echo -e "  4. Run /00_continue to resume from continuation state"
    fi

    echo ""
    echo -e "${RED}Remember: Never quit halfway!${NC}"
    echo -e "${YELLOW}Escape hatch: Use /cancel or /stop to force stop${NC}"

    # Update cache with last run time
    cache_init
    jq --argjson last_run "$CURRENT_TIME" '.last_run["check_todos"] = $last_run' "$CACHE_FILE" > "$CACHE_FILE.tmp" 2>/dev/null && mv "$CACHE_FILE.tmp" "$CACHE_FILE" 2>/dev/null || true

    exit 0  # Don't block exit, just warn
else
    echo -e "${GREEN}✓ All todos completed! Ready for /03_close${NC}"

    # Update cache with last run time
    cache_init
    jq --argjson last_run "$CURRENT_TIME" '.last_run["check_todos"] = $last_run' "$CACHE_FILE" > "$CACHE_FILE.tmp" 2>/dev/null && mv "$CACHE_FILE.tmp" "$CACHE_FILE" 2>/dev/null || true

    exit 0
fi
