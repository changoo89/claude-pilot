#!/bin/bash

# Test SC-3: Content Preservation Verification
# Verify essential content preserved in optimized confirm-plan/REFERENCE.md

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TARGET_FILE="$PROJECT_ROOT/.claude/skills/confirm-plan/REFERENCE.md"

echo "Testing SC-3: Content Preservation in confirm-plan/REFERENCE.md"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Check 1: Dual-Source Extraction workflow (Step 1.1-1.4)
if grep -q "Step 1: Dual-Source Extraction" "$TARGET_FILE" && grep -q "Step 1.1:" "$TARGET_FILE" && grep -q "Step 1.4:" "$TARGET_FILE"; then
    echo "✅ Dual-Source Extraction workflow preserved"
    ((PASS_COUNT++))
else
    echo "❌ Dual-Source Extraction workflow missing"
    ((FAIL_COUNT++))
fi

# Check 2: Requirements Coverage Check methodology
if grep -q "Requirements Coverage Check" "$TARGET_FILE" && grep -q "UR-" "$TARGET_FILE"; then
    echo "✅ Requirements Coverage Check methodology preserved"
    ((PASS_COUNT++))
else
    echo "❌ Requirements Coverage Check methodology missing"
    ((FAIL_COUNT++))
fi

# Check 3: Link to template
if grep -q "@.claude/commands/01_confirm.md" "$TARGET_FILE"; then
    echo "✅ Link to plan template preserved"
    ((PASS_COUNT++))
else
    echo "❌ Link to plan template missing"
    ((FAIL_COUNT++))
fi

# Check 4: GPT delegation reference
if grep -q "@.claude/skills/gpt-delegation" "$TARGET_FILE"; then
    echo "✅ GPT delegation reference preserved"
    ((PASS_COUNT++))
else
    echo "❌ GPT delegation reference missing"
    ((FAIL_COUNT++))
fi

# Check 5: Conversation Highlights section
if grep -q "Conversation Highlights" "$TARGET_FILE"; then
    echo "✅ Conversation Highlights section preserved"
    ((PASS_COUNT++))
else
    echo "❌ Conversation Highlights section missing"
    ((FAIL_COUNT++))
fi

echo ""
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "✅ All essential content preserved"
    exit 0
else
    echo "❌ Some essential content missing"
    exit 1
fi
