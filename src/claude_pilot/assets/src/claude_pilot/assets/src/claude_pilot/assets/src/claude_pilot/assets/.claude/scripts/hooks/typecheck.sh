#!/usr/bin/env bash
# TypeScript Type Check Hook
# Runs before/after file edits to catch type errors early

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if TypeScript is available
if ! command -v tsc &> /dev/null && ! command -v npx &> /dev/null; then
    echo -e "${YELLOW}⚠ TypeScript not found, skipping type check${NC}"
    exit 0
fi

# Check if tsconfig.json exists
if [ ! -f "tsconfig.json" ]; then
    # No TypeScript project, skip silently
    exit 0
fi

echo -e "${BLUE}🔍 Running TypeScript type check...${NC}"

# Run type check
if npx tsc --noEmit 2>&1; then
    echo -e "${GREEN}✓ Type check passed${NC}"
    exit 0
else
    EXIT_CODE=$?
    echo -e "${RED}✗ Type check failed with exit code $EXIT_CODE${NC}"
    echo -e "${YELLOW}Fix type errors before proceeding${NC}"
    exit $EXIT_CODE
fi
