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
                echo -e "${RED}⚠️ WARNING: You are on a protected branch: ${BRANCH}${NC}"
                echo -e "${YELLOW}This command may be destructive:${NC} $COMMAND"
                echo ""
                echo -e "${YELLOW}Protected branches:${NC} ${PROTECTED_BRANCHES[*]}"
                echo ""
                echo -e "${BLUE}Recommendations:${NC}"
                echo "  1. Create a feature branch first"
                echo "  2. Use Pull Requests for merging"
                echo "  3. Get code review before merging to $BRANCH"
                echo ""
                read -p "Continue anyway? [y/N] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${RED}Command aborted${NC}"
                    exit 1
                fi
                ;;
        esac
        break
    fi
done

exit 0
