#!/usr/bin/env bash
# TypeScript Type Check Hook
# Runs before/after file edits to catch type errors early
# Optimized with early exit and caching

set -e

# Cleanup handler for temporary files
cleanup_typecheck_temp_files() {
    # Clean up any temporary files created during execution
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.tmp" ]; then
        rm -f "$CACHE_FILE.tmp" 2>/dev/null || true
    fi
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.lock" ]; then
        rm -f "$CACHE_FILE.lock" 2>/dev/null || true
    fi
}

# Register cleanup trap
trap cleanup_typecheck_temp_files EXIT INT TERM

# Skip during setup to avoid unnecessary full project scans
if [ "$PILOT_SETUP_IN_PROGRESS" = "1" ]; then
  exit 0
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Early exit: Check if tsconfig.json exists
if [ ! -f "tsconfig.json" ]; then
    # No TypeScript project, skip silently
    exit 0
fi

# Early exit: Check if TypeScript is available
if ! command -v tsc &> /dev/null && ! command -v npx &> /dev/null; then
    # TypeScript not available, skip silently
    exit 0
fi

# Load cache functions
CACHE_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/cache.sh"
if [ -f "$CACHE_SCRIPT" ]; then
    # shellcheck source=cache.sh disable=SC1091
    source "$CACHE_SCRIPT"

    # Check cache validity (debounce + config hash)
    if cache_check_valid "typecheck" "tsconfig.json"; then
        # Cache hit: skip type check
        exit 0
    fi
fi

echo -e "${BLUE}🔍 Running TypeScript type check...${NC}"

# Run type check
if npx tsc --noEmit 2>&1; then
    echo -e "${GREEN}✓ Type check passed${NC}"

    # Update cache on success
    if [ -f "$CACHE_SCRIPT" ]; then
        # Detect TypeScript version
        TSC_VERSION=""
        if command -v tsc &> /dev/null; then
            TSC_VERSION=$(tsc --version 2>/dev/null || echo "unknown")
        elif command -v npx &> /dev/null; then
            TSC_VERSION=$(npx tsc --version 2>/dev/null || echo "unknown")
        fi

        # Write cache entry
        cache_write "typescript" "tsc" "$TSC_VERSION" "tsconfig.json" "typecheck"
    fi

    exit 0
else
    EXIT_CODE=$?
    echo -e "${RED}✗ Type check failed with exit code $EXIT_CODE${NC}"
    echo -e "${YELLOW}Fix type errors before proceeding${NC}"
    exit $EXIT_CODE
fi
