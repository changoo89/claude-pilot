#!/usr/bin/env bash
# Lint Hook
# Runs before/after file edits to catch linting issues early

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect available linters
LINTER_FOUND=false

# Try ESLint
if [ -f "package.json" ] && grep -q "\"eslint" package.json; then
    if command -v npx &> /dev/null; then
        LINTER_FOUND=true
        echo -e "${BLUE}🔍 Running ESLint...${NC}"

        if npx eslint . --ext .js,.jsx,.ts,.tsx 2>&1; then
            echo -e "${GREEN}✓ ESLint passed${NC}"
        else
            EXIT_CODE=$?
            echo -e "${RED}✗ ESLint failed with exit code $EXIT_CODE${NC}"
            echo -e "${YELLOW}Fix linting errors before proceeding${NC}"
            exit $EXIT_CODE
        fi
    fi
fi

# Try Pylint for Python
if [ -f "pyproject.toml" ] || [ -f ".pylintrc" ] || [ -f "setup.py" ]; then
    if command -v pylint &> /dev/null; then
        LINTER_FOUND=true
        echo -e "${BLUE}🔍 Running Pylint...${NC}"

        # Find Python files to lint
        PY_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '.py$' || true)

        if [ -n "$PY_FILES" ]; then
            if pylint $PY_FILES; then
                echo -e "${GREEN}✓ Pylint passed${NC}"
            else
                EXIT_CODE=$?
                echo -e "${RED}✗ Pylint failed with exit code $EXIT_CODE${NC}"
                echo -e "${YELLOW}Fix linting errors before proceeding${NC}"
                exit $EXIT_CODE
            fi
        fi
    fi
fi

# Try gofmt for Go
if [ -f "go.mod" ]; then
    LINTER_FOUND=true
    echo -e "${BLUE}🔍 Running gofmt...${NC}"

    if command -v gofmt &> /dev/null; then
        # Check if any Go files need formatting
        UNFORMATTED=$(gofmt -l . 2>/dev/null || true)

        if [ -n "$UNFORMATTED" ]; then
            echo -e "${RED}✗ The following Go files are not properly formatted:${NC}"
            echo "$UNFORMATTED"
            echo -e "${YELLOW}Run 'gofmt -w .' to fix${NC}"
            exit 1
        else
            echo -e "${GREEN}✓ gofmt check passed${NC}"
        fi
    fi
fi

# No linter found
if [ "$LINTER_FOUND" = false ]; then
    # No linter configured, skip silently
    exit 0
fi

exit 0
