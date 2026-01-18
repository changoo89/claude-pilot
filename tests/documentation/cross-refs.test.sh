#!/usr/bin/env bash
# Test: Cross-reference validation for @.claude/ syntax
# Purpose: Verify all @.claude/ references in documentation resolve to existing files
# Test ID: TS-3

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_REFS=0
BROKEN_REFS=0
VALID_REFS=0

# Base directory
BASE_DIR="/Users/chanho/claude-pilot"

echo "======================================"
echo "Cross-Reference Validation Test"
echo "======================================"
echo ""

# Find all @.claude/ references in documentation
echo "Scanning for @.claude/ references..."

REFS=$(grep -rhoE "@\.claude/[a-zA-Z0-9_/\.-]+" \
  "$BASE_DIR/CLAUDE.md" \
  "$BASE_DIR"/docs/ai-context/*.md 2>/dev/null | \
  sed 's/@\.claude\///' | \
  sort -u)

TOTAL_REFS=$(echo "$REFS" | grep -c "^" || echo "0")

echo "Found $TOTAL_REFS unique references"
echo ""

# Validate each reference
echo "Validating references..."
echo ""

while IFS= read -r ref; do
  REF_PATH="$BASE_DIR/.claude/$ref"

  if [ -f "$REF_PATH" ]; then
    echo -e "${GREEN}✓${NC} $ref"
    VALID_REFS=$((VALID_REFS + 1))
  elif [ -d "$REF_PATH" ]; then
    echo -e "${GREEN}✓${NC} $ref (directory)"
    VALID_REFS=$((VALID_REFS + 1))
  else
    echo -e "${RED}✗${NC} $ref (MISSING)"
    BROKEN_REFS=$((BROKEN_REFS + 1))
  fi
done <<< "$REFS"

echo ""
echo "======================================"
echo "Test Results"
echo "======================================"
echo "Total References: $TOTAL_REFS"
echo -e "${GREEN}Valid: $VALID_REFS${NC}"
if [ $BROKEN_REFS -gt 0 ]; then
  echo -e "${RED}Broken: $BROKEN_REFS${NC}"
else
  echo "Broken: $BROKEN_REFS"
fi
echo ""

# Exit with appropriate code
if [ $BROKEN_REFS -eq 0 ]; then
  echo -e "${GREEN}PASS: All cross-references resolve${NC}"
  exit 0
else
  echo -e "${RED}FAIL: $BROKEN_REFS broken references found${NC}"
  exit 1
fi
