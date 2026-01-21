#!/usr/bin/env bash
# Simple pre-commit hook for claude-pilot plugin
# Focus: Fast validation of critical files only

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔍 Running pre-commit checks...${NC}"

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Skip if no files staged
if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# Track errors
ERRORS=0

# Check JSON files for syntax errors
for file in $STAGED_FILES; do
    if [[ "$file" == *.json ]]; then
        if ! jq empty "$file" &>/dev/null; then
            echo -e "${RED}✗ Invalid JSON: $file${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Check markdown files for broken links (lightweight check)
for file in $STAGED_FILES; do
    if [[ "$file" == *.md ]]; then
        # Check for common markdown link issues
        if grep -E '\[.*\]\(\s*\)' "$file" &>/dev/null; then
            echo -e "${YELLOW}⚠ Empty link found in: $file${NC}"
        fi
    fi
done

# Final result
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✗ Pre-commit check failed with $ERRORS error(s)${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Pre-commit checks passed${NC}"
    exit 0
fi
