#!/usr/bin/env bash
# Ralph Continuation Enforcement Hook
# Runs on session stop to ensure todos are properly completed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check for incomplete todos in the plan
INCOMPLETE=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null || echo "0")

if [ "$INCOMPLETE" -gt "0" ]; then
    echo -e "${YELLOW}⚠ Ralph Continuation Warning:${NC}"
    echo -e "  You have $INCOMPLETE incomplete todo(s) in your plan."
    echo -e "  ${YELLOW}Plan location:${NC} $PLAN_FILE"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  1. Complete the todos and run /03_close"
    echo -e "  2. Create sub-tasks for blocked items"
    echo -e "  3. Update plan to reflect actual completion status"
    echo ""
    echo -e "${RED}Remember: Never quit halfway!${NC}"
    exit 0  # Don't block exit, just warn
else
    echo -e "${GREEN}✓ All todos completed! Ready for /03_close${NC}"
    exit 0
fi
