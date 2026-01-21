#!/usr/bin/env bash
# Lint Hook
# Runs before/after file edits to catch linting issues early
# Optimized with early exit and caching

# Source common environment library
# shellcheck source=../../lib/env.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../../lib/env.sh" ]]; then
    source "$SCRIPT_DIR/../../lib/env.sh"
fi

set -e

# Cleanup handler for temporary files
cleanup_lint_temp_files() {
    # Clean up any temporary files created during execution
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.tmp" ]; then
        rm -f "$CACHE_FILE.tmp" 2>/dev/null || true
    fi
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.lock" ]; then
        rm -f "$CACHE_FILE.lock" 2>/dev/null || true
    fi
}

# Register cleanup trap
trap cleanup_lint_temp_files EXIT INT TERM

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

# Load cache functions
CACHE_SCRIPT="${SCRIPT_DIR}/cache.sh"
LINTER_FOUND=false

# Try ESLint
if [ -f "package.json" ] && grep -q "\"eslint" package.json; then
    # Early exit: Check if npx is available
    if ! command -v npx &> /dev/null; then
        # ESLint configured but npx not available, skip silently
        true
    else
        LINTER_FOUND=true

        # Check cache validity
        CACHE_HIT=false
        if [ -f "$CACHE_SCRIPT" ]; then
            # shellcheck source=cache.sh disable=SC1091
            source "$CACHE_SCRIPT"

            if cache_check_valid "lint" "package.json"; then
                # Cache hit: skip ESLint
                CACHE_HIT=true
            fi
        fi

        if [ "$CACHE_HIT" = false ]; then
            echo -e "${BLUE}🔍 Running ESLint...${NC}"

            if npx eslint . --ext .js,.jsx,.ts,.tsx 2>&1; then
                echo -e "${GREEN}✓ ESLint passed${NC}"

                # Update cache on success
                if [ -f "$CACHE_SCRIPT" ]; then
                    ESLINT_VERSION=$(npx eslint --version 2>/dev/null || echo "unknown")
                    cache_write "nodejs" "eslint" "$ESLINT_VERSION" "package.json" "lint"
                fi
            else
                EXIT_CODE=$?
                echo -e "${RED}✗ ESLint failed with exit code $EXIT_CODE${NC}"
                echo -e "${YELLOW}Fix linting errors before proceeding${NC}"
                exit $EXIT_CODE
            fi
        fi
    fi
fi

# Try Pylint for Python
if [ -f "pyproject.toml" ] || [ -f ".pylintrc" ] || [ -f "setup.py" ]; then
    # Early exit: Check if pylint is available
    if ! command -v pylint &> /dev/null; then
        # Python project but pylint not available, skip silently
        true
    else
        LINTER_FOUND=true

        # Check cache validity
        CACHE_HIT=false
        CACHE_FILE="pyproject.toml"
        if [ ! -f "$CACHE_FILE" ]; then
            CACHE_FILE=".pylintrc"
        fi
        if [ ! -f "$CACHE_FILE" ]; then
            CACHE_FILE="setup.py"
        fi

        if [ -f "$CACHE_SCRIPT" ] && [ -f "$CACHE_FILE" ]; then
            # shellcheck source=cache.sh disable=SC1091
            source "$CACHE_SCRIPT"

            if cache_check_valid "lint" "$CACHE_FILE"; then
                # Cache hit: skip Pylint
                CACHE_HIT=true
            fi
        fi

        if [ "$CACHE_HIT" = false ]; then
            echo -e "${BLUE}🔍 Running Pylint...${NC}"

            # Find Python files to lint
            PY_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '.py$' || true)

            if [ -n "$PY_FILES" ]; then
                # shellcheck disable=SC2086
                if pylint $PY_FILES 2>&1; then
                    echo -e "${GREEN}✓ Pylint passed${NC}"

                    # Update cache on success
                    if [ -f "$CACHE_SCRIPT" ]; then
                        PYLINT_VERSION=$(pylint --version 2>&1 | head -n1 | awk '{print $2}' || echo "unknown")
                        cache_write "python" "pylint" "$PYLINT_VERSION" "$CACHE_FILE" "lint"
                    fi
                else
                    EXIT_CODE=$?
                    echo -e "${RED}✗ Pylint failed with exit code $EXIT_CODE${NC}"
                    echo -e "${YELLOW}Fix linting errors before proceeding${NC}"
                    exit $EXIT_CODE
                fi
            fi
        fi
    fi
fi

# Try gofmt for Go
if [ -f "go.mod" ]; then
    # Early exit: Check if gofmt is available
    if ! command -v gofmt &> /dev/null; then
        # Go project but gofmt not available, skip silently
        true
    else
        LINTER_FOUND=true

        # Check cache validity
        CACHE_HIT=false
        if [ -f "$CACHE_SCRIPT" ]; then
            # shellcheck source=cache.sh disable=SC1091
            source "$CACHE_SCRIPT"

            if cache_check_valid "lint" "go.mod"; then
                # Cache hit: skip gofmt
                CACHE_HIT=true
            fi
        fi

        if [ "$CACHE_HIT" = false ]; then
            echo -e "${BLUE}🔍 Running gofmt...${NC}"

            # Check if any Go files need formatting
            UNFORMATTED=$(gofmt -l . 2>/dev/null || true)

            if [ -n "$UNFORMATTED" ]; then
                echo -e "${RED}✗ The following Go files are not properly formatted:${NC}"
                echo "$UNFORMATTED"
                echo -e "${YELLOW}Run 'gofmt -w .' to fix${NC}"
                exit 1
            else
                echo -e "${GREEN}✓ gofmt check passed${NC}"

                # Update cache on success
                if [ -f "$CACHE_SCRIPT" ]; then
                    GOFMT_VERSION=$(go version 2>&1 | awk '{print $3}' || echo "unknown")
                    cache_write "go" "gofmt" "$GOFMT_VERSION" "go.mod" "lint"
                fi
            fi
        fi
    fi
fi

# No linter found
if [ "$LINTER_FOUND" = false ]; then
    # No linter configured, skip silently
    exit 0
fi

exit 0
