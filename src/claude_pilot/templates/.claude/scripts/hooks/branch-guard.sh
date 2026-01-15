#!/usr/bin/env bash
# Branch Guard Hook
# Warns before running dangerous commands on important branches

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get current branch
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

if [ -z "$BRANCH" ]; then
    # Not in a git repo
    exit 0
fi

# Protected branches
PROTECTED_BRANCHES=("main" "master" "develop" "development" "prod" "production")

# Check if current branch is protected
for PROTECTED in "${PROTECTED_BRANCHES[@]}"; do
    if [ "$BRANCH" = "$PROTECTED" ]; then
        # Check if the command is from arguments
        COMMAND="$1"

        case "$COMMAND" in
            *rm*|*delete*|*drop*|*reset*|*revert*)
                # Output to stderr for Claude Code hook feedback
                echo -e "${RED}⚠️ BLOCKED: Destructive command on protected branch '${BRANCH}'${NC}" >&2
                echo -e "${YELLOW}Command:${NC} $COMMAND" >&2
                echo "" >&2
                echo -e "${BLUE}Recommendations:${NC}" >&2
                echo "  1. Create a feature branch: git checkout -b feature/your-change" >&2
                echo "  2. Make changes on the feature branch" >&2
                echo "  3. Use Pull Request to merge to $BRANCH" >&2
                echo "" >&2
                echo -e "${YELLOW}Protected branches:${NC} ${PROTECTED_BRANCHES[*]}" >&2
                # Exit code 2 = blocking error (stderr fed back to Claude)
                exit 2
                ;;
        esac
        break
    fi
done

exit 0
