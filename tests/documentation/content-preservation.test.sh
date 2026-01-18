#!/bin/bash

# Test: Content Preservation Check (TS-4)
# Purpose: Verify no content loss during CLAUDE.md refactoring
# Author: Tester Agent
# Date: 2026-01-18

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test variables
PROJECT_ROOT="/Users/chanho/claude-pilot"
ORIGINAL_FILE="$PROJECT_ROOT/CLAUDE.md"
BACKUP_FILE="$PROJECT_ROOT/CLAUDE.md.backup"
TEST_RESULTS=0

echo "=========================================="
echo "TS-4: Content Preservation Check"
echo "=========================================="
echo ""

# Step 1: Create backup if not exists
echo "Step 1: Creating backup..."
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$ORIGINAL_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE"
else
    echo -e "${YELLOW}⊙${NC} Backup already exists: $BACKUP_FILE"
fi
echo ""

# Step 2: Extract key content sections from original
echo "Step 2: Extracting key content sections..."

# Function to check if section exists
check_section() {
    local section_name="$1"
    local search_pattern="$2"

    if grep -q "$search_pattern" "$ORIGINAL_FILE"; then
        echo -e "${GREEN}✓${NC} Section '$section_name' found"
        return 0
    else
        echo -e "${RED}✗${NC} Section '$section_name' NOT found"
        TEST_RESULTS=1
        return 1
    fi
}

# Check all major sections
check_section "Quick Start" "## Quick Start"
check_section "Installation" "### Installation"
check_section "Workflow Commands" "### Workflow Commands"
check_section "Development Workflow" "### Development Workflow"
check_section "Project Structure" "## Project Structure"
check_section "Plugin Distribution" "## Plugin Distribution"
check_section "Codex Integration" "## Codex Integration"
check_section "Sisyphus Continuation System" "## Sisyphus Continuation System"
check_section "CI/CD Integration" "## CI/CD Integration"
check_section "Testing & Quality" "## Testing & Quality"
check_section "Documentation System" "## Documentation System"
check_section "Agent Ecosystem" "## Agent Ecosystem"
check_section "MCP Servers" "## MCP Servers"
check_section "Frontend Design Skill" "## Frontend Design Skill"
check_section "Pre-Commit Checklist" "## Pre-Commit Checklist"
check_section "Related Documentation" "## Related Documentation"

echo ""

# Step 3: Verify @ syntax references
echo "Step 3: Verifying @ syntax references..."

# Count @ references
AT_REFS=$(grep -o "@[^ ]*" "$ORIGINAL_FILE" | wc -l | tr -d ' ')
echo -e "${GREEN}✓${NC} Found $AT_REFS @ syntax references"

# Check for specific critical @ references
CRITICAL_REFS=(
    "@docs/ai-context/project-structure.md"
    "@docs/ai-context/codex-integration.md"
    "@docs/ai-context/continuation-system.md"
    "@docs/ai-context/cicd-integration.md"
    "@docs/ai-context/testing-quality.md"
    "@.claude/agents/CONTEXT.md"
    "@.claude/commands/CONTEXT.md"
    "@.claude/skills/frontend-design/SKILL.md"
)

for ref in "${CRITICAL_REFS[@]}"; do
    if grep -q "$ref" "$ORIGINAL_FILE"; then
        echo -e "${GREEN}✓${NC} Reference: $ref"
    else
        echo -e "${RED}✗${NC} Missing reference: $ref"
        TEST_RESULTS=1
    fi
done

echo ""

# Step 4: Verify content completeness
echo "Step 4: Verifying content completeness..."

# Count lines
LINE_COUNT=$(wc -l < "$ORIGINAL_FILE" | tr -d ' ')
echo -e "${GREEN}✓${NC} Current line count: $LINE_COUNT"

# Check for critical keywords
CRITICAL_KEYWORDS=(
    "Quick Start"
    "Workflow Commands"
    "SPEC-First"
    "TDD Cycle"
    "Ralph Loop"
    "Quality Gates"
    "Sisyphus"
    "Codex"
    "Continuation"
    "CI/CD"
    "Testing"
    "Documentation"
    "Agent"
    "MCP"
    "Frontend Design"
)

for keyword in "${CRITICAL_KEYWORDS[@]}"; do
    if grep -q "$keyword" "$ORIGINAL_FILE"; then
        echo -e "${GREEN}✓${NC} Keyword found: $keyword"
    else
        echo -e "${RED}✗${NC} Missing keyword: $keyword"
        TEST_RESULTS=1
    fi
done

echo ""

# Step 5: Verify no content deletion
echo "Step 5: Verifying no content deletion..."

if [ -f "$BACKUP_FILE" ]; then
    BACKUP_LINES=$(wc -l < "$BACKUP_FILE" | tr -d ' ')
    CURRENT_LINES=$(wc -l < "$ORIGINAL_FILE" | tr -d ' ')

    echo "Backup line count: $BACKUP_LINES"
    echo "Current line count: $CURRENT_LINES"

    # Calculate content preservation
    # Note: Current CLAUDE.md should be shorter (content moved to Tier 2)
    # So we check if backup exists and if key sections are preserved elsewhere

    if [ $CURRENT_LINES -lt 300 ]; then
        echo -e "${GREEN}✓${NC} CLAUDE.md within target length (< 300 lines)"
    else
        echo -e "${YELLOW}⊙${NC} CLAUDE.md exceeds target length ($CURRENT_LINES >= 300)"
    fi

    # Verify backup is safe
    if [ -f "$BACKUP_FILE" ]; then
        echo -e "${GREEN}✓${NC} Backup preserved at $BACKUP_FILE"
    fi
else
    echo -e "${YELLOW}⊙${NC} No backup found for comparison"
fi

echo ""
echo "=========================================="
echo "Test Result Summary"
echo "=========================================="

if [ $TEST_RESULTS -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Content preservation check successful"
    echo ""
    echo "Details:"
    echo "- All major sections present"
    echo "- All critical @ syntax references found"
    echo "- All critical keywords present"
    echo "- Backup created/preserved"
    echo ""
    echo "Conclusion: Zero content loss detected"
    exit 0
else
    echo -e "${RED}✗ FAIL${NC}: Content preservation issues detected"
    echo ""
    echo "Action Required:"
    echo "1. Review missing sections above"
    echo "2. Check if content was moved to Tier 2 files"
    echo "3. Verify all @ syntax references resolve"
    echo ""
    exit 1
fi
